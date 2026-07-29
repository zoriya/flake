package ui

import (
	"testing"

	"github.com/charmbracelet/bubbles/textinput"

	"claude-mux/internal/manager"
	"claude-mux/internal/session"
)

func newTestModel(n, height int) *model {
	entries := make([]manager.Entry, n)
	m := &model{entries: entries, height: height, width: 80}
	return m
}

func TestPageSizeTwoLineLayout(t *testing.T) {
	// height 24, width 80: header(1) + footer(help 1 line + position 1) = 3,
	// body 21, two lines per entry -> 10 entries.
	m := newTestModel(0, 24)
	if got := m.pageSize(); got != 10 {
		t.Fatalf("pageSize = %d, want 10", got)
	}
	m.height = 0 // defaults to 24
	if got := m.pageSize(); got != 10 {
		t.Fatalf("pageSize(default) = %d, want 10", got)
	}
	m.height = 3 // too small for even one two-line entry -> still 1
	if got := m.pageSize(); got != 1 {
		t.Fatalf("pageSize(tiny) = %d, want 1", got)
	}
}

func TestClampScrollKeepsCursorVisible(t *testing.T) {
	m := newTestModel(20, 10)
	page := m.pageSize()

	m.cursor = 19
	m.clampScroll()
	if m.cursor < m.offset || m.cursor >= m.offset+page {
		t.Fatalf("cursor %d not visible in [%d,%d)", m.cursor, m.offset, m.offset+page)
	}

	m.cursor = 0
	m.clampScroll()
	if m.offset != 0 {
		t.Fatalf("offset = %d, want 0", m.offset)
	}
}

func TestClampScrollOffsetNeverPastEnd(t *testing.T) {
	m := newTestModel(20, 10)
	page := m.pageSize()
	m.offset = 100
	m.cursor = 19
	m.clampScroll()
	maxOff := len(m.entries) - page
	if m.offset != maxOff {
		t.Fatalf("offset = %d, want %d (max)", m.offset, maxOff)
	}
}

func TestClampScrollFewerEntriesThanPage(t *testing.T) {
	m := newTestModel(3, 24) // pageSize 10 > 3
	m.cursor = 2
	m.clampScroll()
	if m.offset != 0 {
		t.Fatalf("offset = %d, want 0 (no scroll needed)", m.offset)
	}
}

func TestApplyFilterMatchesTitlesCaseInsensitively(t *testing.T) {
	m := &model{width: 80, height: 24, search: textinput.New()}
	m.raw = []manager.Entry{
		{Session: session.Session{ID: "1", Title: "Fix the parser"}},
		{Session: session.Session{ID: "2", Title: "Add search to picker"}},
		{Session: session.Session{ID: "3", Title: "Refactor SEARCH index"}},
	}

	// Empty query shows everything (and shares the raw slice).
	m.applyFilter()
	if len(m.entries) != 3 {
		t.Fatalf("empty query: got %d entries, want 3", len(m.entries))
	}

	// A query narrows to matching titles, ignoring case.
	m.search.SetValue("search")
	m.applyFilter()
	if len(m.entries) != 2 {
		t.Fatalf("query %q: got %d entries, want 2", m.search.Value(), len(m.entries))
	}
	if m.entries[0].ID != "2" || m.entries[1].ID != "3" {
		t.Fatalf("query %q matched wrong entries: %v", m.search.Value(), m.entries)
	}

	// A non-matching query yields an empty list but keeps raw intact.
	m.search.SetValue("deploy")
	m.applyFilter()
	if len(m.entries) != 0 {
		t.Fatalf("query %q: got %d entries, want 0", m.search.Value(), len(m.entries))
	}
	if len(m.raw) != 3 {
		t.Fatalf("raw was mutated: got %d, want 3", len(m.raw))
	}
}
