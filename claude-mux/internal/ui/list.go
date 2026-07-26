// Package ui renders the floating session picker shown by "claude-mux list".
package ui

import (
	"fmt"
	"path/filepath"
	"strings"
	"time"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"

	"claude-mux/internal/manager"
	"claude-mux/internal/session"
	"claude-mux/internal/tmux"
)

// Action is what the user chose to do when the picker closed.
type Action int

const (
	// ActionNone means the picker was cancelled.
	ActionNone Action = iota
	// ActionResume means open the selected session (Result.Entry).
	ActionResume
	// ActionNew means start a fresh session.
	ActionNew
)

// Result is the outcome of running the picker.
type Result struct {
	Action Action
	Entry  manager.Entry
}

var (
	titleStyle  = lipgloss.NewStyle().Bold(true)
	dirStyle    = lipgloss.NewStyle().Foreground(lipgloss.Color("39"))
	helpStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("242"))
	dimStyle    = lipgloss.NewStyle().Foreground(lipgloss.Color("244"))
	metaStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("246"))
	projStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("39"))
	selBar      = lipgloss.NewStyle().Foreground(lipgloss.Color("39"))
	selRowStyle = lipgloss.NewStyle().Bold(true)
	emptyStyle  = lipgloss.NewStyle().Foreground(lipgloss.Color("244")).Italic(true)

	// Per-status colours.
	runningStyle  = lipgloss.NewStyle().Foreground(lipgloss.Color("42"))  // green
	questionStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("214")) // amber
	openStyle     = lipgloss.NewStyle().Foreground(lipgloss.Color("39"))  // blue
	closedStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("240")) // dim
)

// statusDot returns a coloured glyph for a session status.
func statusDot(s session.Status) string {
	switch s {
	case session.StatusRunning:
		return runningStyle.Render("●")
	case session.StatusQuestions:
		return questionStyle.Render("?")
	case session.StatusIdle:
		return openStyle.Render("○")
	default: // closed
		return closedStyle.Render("·")
	}
}

// statusWord returns the human label for a session status.
func statusWord(s session.Status) string {
	switch s {
	case session.StatusRunning:
		return "running"
	case session.StatusQuestions:
		return "waiting for you"
	case session.StatusIdle:
		return "open"
	default:
		return "closed"
	}
}

type model struct {
	dir     string
	srv     *tmux.Server
	all     bool
	entries []manager.Entry
	cursor  int
	offset  int // index of the first visible row (scrolling)
	width   int
	height  int
	err     error
	result  Result
}

// RunPicker shows the interactive picker for dir and returns the chosen action.
// When all is true it starts listing sessions across every project.
func RunPicker(dir string, all bool, srv *tmux.Server) (Result, error) {
	m := &model{dir: dir, all: all, srv: srv}
	m.reload()
	p := tea.NewProgram(m, tea.WithAltScreen())
	final, err := p.Run()
	if err != nil {
		return Result{}, err
	}
	return final.(*model).result, nil
}

func (m *model) reload() {
	entries, err := manager.Load(m.dir, m.all, m.srv)
	m.err = err
	m.entries = entries
	if m.cursor >= len(entries) {
		m.cursor = len(entries) - 1
	}
	if m.cursor < 0 {
		m.cursor = 0
	}
}

func (m *model) Init() tea.Cmd { return nil }

// linesPerEntry is the height of one rendered session (two-line layout).
const linesPerEntry = 2

func (m *model) dims() (width, height int) {
	width, height = m.width, m.height
	if width <= 0 {
		width = 80
	}
	if height <= 0 {
		height = 24
	}
	return
}

// footerHeight is how many lines the (wrapped) help text plus the position line
// occupy at the current width.
func (m *model) footerHeight() int {
	width, _ := m.dims()
	return lipgloss.Height(helpStyle.Width(width).Render(m.helpText())) + 1
}

// pageSize is how many session entries fit, given the two-line layout and the
// space taken by the header (1 line) and footer.
func (m *model) pageSize() int {
	_, height := m.dims()
	body := height - 1 - m.footerHeight()
	if body < linesPerEntry {
		return 1
	}
	return body / linesPerEntry
}

// clampScroll keeps the cursor within the visible window and the offset in range.
func (m *model) clampScroll() {
	page := m.pageSize()
	if m.cursor < m.offset {
		m.offset = m.cursor
	}
	if m.cursor >= m.offset+page {
		m.offset = m.cursor - page + 1
	}
	maxOff := len(m.entries) - page
	if maxOff < 0 {
		maxOff = 0
	}
	if m.offset > maxOff {
		m.offset = maxOff
	}
	if m.offset < 0 {
		m.offset = 0
	}
}

func (m *model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width, m.height = msg.Width, msg.Height
		m.clampScroll()
	case tea.KeyMsg:
		switch msg.String() {
		case "ctrl+c", "q", "esc":
			m.result = Result{Action: ActionNone}
			return m, tea.Quit
		case "up", "k":
			if m.cursor > 0 {
				m.cursor--
			}
		case "down", "j":
			if m.cursor < len(m.entries)-1 {
				m.cursor++
			}
		case "g", "home":
			m.cursor = 0
		case "G", "end":
			m.cursor = len(m.entries) - 1
		case "r":
			m.reload()
		case "ctrl+a":
			m.all = !m.all
			m.cursor = 0
			m.reload()
		case "n":
			m.result = Result{Action: ActionNew}
			return m, tea.Quit
		case "x":
			// Kill the selected session's running window. Idle sessions have no
			// live process, so there is nothing to kill.
			if len(m.entries) > 0 {
				if e := m.entries[m.cursor]; e.Target != "" {
					_ = m.srv.KillWindow(e.Target)
					m.reload()
				}
			}
		case "enter":
			if len(m.entries) > 0 {
				m.result = Result{Action: ActionResume, Entry: m.entries[m.cursor]}
				return m, tea.Quit
			}
		}
		m.clampScroll()
	}
	return m, nil
}

func (m *model) View() string {
	width, _ := m.dims()
	var b strings.Builder

	b.WriteString(m.renderHeader(width))
	b.WriteString("\n")

	if m.err != nil {
		b.WriteString(emptyStyle.Width(width).Render("error: " + m.err.Error()))
		return b.String()
	}
	if len(m.entries) == 0 {
		msg := "No sessions yet for this project."
		if m.all {
			msg = "No sessions found."
		}
		b.WriteString(emptyStyle.Width(width).Render(msg))
		b.WriteString("\n")
		b.WriteString(m.renderFooter(width))
		return b.String()
	}

	page := m.pageSize()
	end := m.offset + page
	if end > len(m.entries) {
		end = len(m.entries)
	}
	for i := m.offset; i < end; i++ {
		b.WriteString(m.renderRow(i, m.entries[i], width))
		b.WriteString("\n")
	}
	b.WriteString(m.renderFooter(width))
	return b.String()
}

// renderHeader is the single (truncated) title line.
func (m *model) renderHeader(width int) string {
	scope := m.dir
	if m.all {
		scope = "all projects"
	}
	const prefix = "Claude sessions · "
	avail := width - len([]rune(prefix))
	if avail < 4 {
		return titleStyle.Render(truncate("Claude sessions", width))
	}
	return titleStyle.Render("Claude sessions") + dimStyle.Render(" · ") + dirStyle.Render(truncate(scope, avail))
}

// renderFooter renders the wrapped help text plus a position/summary line.
func (m *model) renderFooter(width int) string {
	help := helpStyle.Width(width).Render(m.helpText())
	return help + "\n" + dimStyle.Render(m.positionText())
}

// positionText summarises how much of the list is shown.
func (m *model) positionText() string {
	total := len(m.entries)
	if total == 0 {
		return ""
	}
	page := m.pageSize()
	if total > page {
		end := m.offset + page
		if end > total {
			end = total
		}
		return fmt.Sprintf("%d–%d of %d", m.offset+1, end, total)
	}
	if total == 1 {
		return "1 session"
	}
	return fmt.Sprintf("%d sessions", total)
}

// renderRow renders one session across two lines: title on top, status/meta
// below. The two-line layout keeps everything readable in narrow popups.
func (m *model) renderRow(i int, e manager.Entry, width int) string {
	selected := i == m.cursor

	// Line 1: selection bar + status dot + title.
	bar := "  "
	if selected {
		bar = selBar.Render("▌ ")
	}
	dot := statusDot(e.Status)
	titleW := width - 4 // bar(2) + dot(1) + space(1)
	if titleW < 4 {
		titleW = 4
	}
	title := truncate(e.Title, titleW)
	if selected {
		title = selRowStyle.Render(title)
	} else {
		title = titleStyle.Render(title)
	}
	line1 := bar + dot + " " + title

	// Line 2: indented status/meta, continuing the selection bar.
	indent := "    "
	if selected {
		indent = selBar.Render("▌ ") + "  "
	}
	parts := []string{statusWord(e.Status)}
	if m.all {
		parts = append(parts, filepath.Base(e.ProjectDir))
	}
	parts = append(parts, fmt.Sprintf("%d msg", e.Messages), relTime(e.Updated))
	meta := truncate(strings.Join(parts, " · "), width-4)
	line2 := indent + metaStyle.Render(meta)

	return line1 + "\n" + line2
}

func (m *model) helpText() string {
	scope := "ctrl+a all"
	if m.all {
		scope = "ctrl+a this project"
	}
	return "↑/↓ move · enter open · n new · x kill · " + scope + " · r refresh · q cancel"
}

// pad right-pads s to at least n runes.
func pad(s string, n int) string {
	if len(s) >= n {
		return s
	}
	return s + strings.Repeat(" ", n-len(s))
}

// truncate shortens s to at most n runes, adding an ellipsis when cut.
func truncate(s string, n int) string {
	r := []rune(s)
	if len(r) <= n {
		return s
	}
	if n <= 1 {
		return string(r[:n])
	}
	return string(r[:n-1]) + "…"
}

// relTime renders a compact "time ago" string, or a date for older sessions.
func relTime(t time.Time) string {
	if t.IsZero() {
		return "—"
	}
	d := time.Since(t)
	switch {
	case d < time.Minute:
		return "just now"
	case d < time.Hour:
		return fmt.Sprintf("%dm ago", int(d.Minutes()))
	case d < 24*time.Hour:
		return fmt.Sprintf("%dh ago", int(d.Hours()))
	case d < 7*24*time.Hour:
		return fmt.Sprintf("%dd ago", int(d.Hours()/24))
	default:
		return t.Format("Jan 2")
	}
}
