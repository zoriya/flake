// Package ui renders the floating session picker shown by "claude-mux list".
package ui

import (
	"fmt"
	"path/filepath"
	"strings"
	"time"

	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"

	"claude-mux/internal/manager"
	"claude-mux/internal/session"
	"claude-mux/internal/state"
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
	// archivedHeaderStyle labels the divider between live and archived sessions.
	archivedHeaderStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("240")).Bold(true)
	// archivedTint / archivedMetaStyle mute archived rows so they read as "put
	// away" at a glance, distinct from the live sessions above the divider.
	archivedTint      = lipgloss.Color("240")
	archivedMetaStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("238"))
	// currentTag marks the row whose session is open in the pane the picker was
	// floated over ("you are here").
	currentTag = lipgloss.NewStyle().Foreground(lipgloss.Color("42")).Bold(true)
	// searchStyle renders the "/query" search prompt in the footer.
	searchStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("214"))

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
		return questionStyle.Render("⬤")
	case session.StatusIdle:
		return openStyle.Render("⬤")
	default: // closed
		return closedStyle.Render("◯")
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
	current string          // session id open in the pane the picker was floated over
	raw     []manager.Entry // every loaded session, before the title filter
	entries []manager.Entry // raw narrowed to the active search query
	search  textinput.Model // the "/" title filter; focused == actively searching
	cursor  int
	offset  int // index of the first visible row (scrolling)
	width   int
	height  int
	err     error
	result  Result
	loading bool // a background load is in flight
	loaded  bool // at least one load has completed
}

// RunPicker shows the interactive picker for dir and returns the chosen action.
// When all is true it starts listing sessions across every project.
func RunPicker(dir string, all bool, srv *tmux.Server) (Result, error) {
	ti := textinput.New()
	ti.Prompt = "/"
	ti.PromptStyle = searchStyle
	ti.Placeholder = "filter by title"
	m := &model{dir: dir, all: all, srv: srv, search: ti}
	if srv.InsideOurServer() {
		m.current = srv.CurrentSessionID()
	}
	p := tea.NewProgram(m, tea.WithAltScreen())
	final, err := p.Run()
	if err != nil {
		return Result{}, err
	}
	return final.(*model).result, nil
}

// loadedMsg carries the result of a background session load.
type loadedMsg struct {
	entries []manager.Entry
	err     error
}

// startLoad kicks off a background load unless one is already running, so the
// picker paints and stays responsive while sessions are read off the main loop.
// Returns nil when a load is already in flight (the tick just skips this round).
func (m *model) startLoad() tea.Cmd {
	if m.loading {
		return nil
	}
	m.loading = true
	dir, all, srv := m.dir, m.all, m.srv
	return func() tea.Msg {
		entries, err := manager.Load(dir, all, srv)
		return loadedMsg{entries: entries, err: err}
	}
}

// applyLoad folds a completed load into the model, keeping the cursor on the
// same session even when attention sorting reorders the list.
func (m *model) applyLoad(msg loadedMsg) {
	firstLoad := !m.loaded
	m.loading = false
	m.loaded = true
	m.err = msg.err
	if msg.err != nil {
		return
	}

	// After the first load, keep the cursor on whatever session it was already
	// pointing at (attention sorting can reorder the list). On the very first
	// load there is nothing to track yet, so start the cursor on the current
	// session — the one open in the pane the picker was floated over.
	var selectedID string
	if firstLoad {
		selectedID = m.current
	} else if m.cursor >= 0 && m.cursor < len(m.entries) {
		selectedID = m.entries[m.cursor].ID
	}
	m.raw = msg.entries
	m.applyFilter()
	if selectedID != "" {
		for i, e := range m.entries {
			if e.ID == selectedID {
				m.cursor = i
				break
			}
		}
	}
	if m.cursor >= len(m.entries) {
		m.cursor = len(m.entries) - 1
	}
	if m.cursor < 0 {
		m.cursor = 0
	}
	m.clampScroll()
}

// applyFilter narrows m.raw into m.entries by the active search query, matching
// case-insensitively against session titles. An empty query shows everything.
func (m *model) applyFilter() {
	q := strings.ToLower(strings.TrimSpace(m.search.Value()))
	if q == "" {
		m.entries = m.raw
		return
	}
	filtered := make([]manager.Entry, 0, len(m.raw))
	for _, e := range m.raw {
		if strings.Contains(strings.ToLower(e.Title), q) {
			filtered = append(filtered, e)
		}
	}
	m.entries = filtered
}

// searchActive reports whether the search box is open (focused) or a title
// filter is otherwise in play.
func (m *model) searchActive() bool { return m.search.Focused() || m.search.Value() != "" }

// reloadInterval is how often an open picker re-reads sessions so its statuses,
// titles and message counts stay live without the user pressing "r".
const reloadInterval = time.Second

// tickMsg is delivered on every reload tick.
type tickMsg struct{}

func tick() tea.Cmd {
	return tea.Tick(reloadInterval, func(time.Time) tea.Msg { return tickMsg{} })
}

func (m *model) Init() tea.Cmd { return tea.Batch(m.startLoad(), tick()) }

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
	h := lipgloss.Height(helpStyle.Width(width).Render(m.helpText())) + 1
	if m.searchActive() {
		h++ // the "/query" search line sits above the help
	}
	return h
}

// hasArchived reports whether any entry is archived, i.e. whether the archived
// section header will be drawn somewhere in the list.
func (m *model) hasArchived() bool {
	for i := range m.entries {
		if m.entries[i].Archived {
			return true
		}
	}
	return false
}

// pageSize is how many session entries fit, given the two-line layout and the
// space taken by the header (1 line) and footer. When an archived section
// exists, one more line is reserved for its divider header.
func (m *model) pageSize() int {
	_, height := m.dims()
	body := height - 1 - m.footerHeight()
	if m.hasArchived() {
		body -= archivedDividerHeight
	}
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
	case loadedMsg:
		m.applyLoad(msg)
		return m, nil
	case tickMsg:
		return m, tea.Batch(m.startLoad(), tick())
	case tea.WindowSizeMsg:
		m.width, m.height = msg.Width, msg.Height
		m.clampScroll()
	case tea.KeyMsg:
		if m.search.Focused() {
			return m.updateSearch(msg)
		}
		var cmd tea.Cmd
		switch msg.String() {
		case "ctrl+c", "q", "esc":
			m.result = Result{Action: ActionNone}
			return m, tea.Quit
		case "/":
			// Open the search box; Focus returns the cursor-blink command.
			return m, m.search.Focus()
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
		case "ctrl+a":
			m.all = !m.all
			m.cursor = 0
			cmd = m.startLoad()
		case "n":
			m.result = Result{Action: ActionNew}
			return m, tea.Quit
		case "x":
			// Archive the selected session: close any live window and drop it to
			// the archived section. Archiving is one-way here — a session is
			// restored by opening it with enter (or previewed with p).
			if len(m.entries) > 0 {
				e := m.entries[m.cursor]
				if !e.Archived {
					// A remote session shares the project's rc window with the
					// server itself, so killing it would take the whole
					// remote-control endpoint down with it: only file it away.
					if e.Target != "" && !e.Remote {
						_ = m.srv.KillWindow(e.Target)
					}
					_ = state.Archive(e.ID)
					// Keep the cursor where it is rather than following the
					// session down to the archived section: point it at the next
					// entry so applyLoad tracks that one (which shifts up into the
					// archived session's old slot) after the reload.
					if m.cursor+1 < len(m.entries) {
						m.cursor++
					}
					cmd = m.startLoad()
				} else if e.Target != "" {
					// The session is already archived but was opened (e.g. via
					// preview), so it has a live window: x closes that pane
					// without changing its archived state.
					_ = m.srv.KillWindow(e.Target)
					cmd = m.startLoad()
				}
			}
		case "enter":
			// Opening an archived session restores it (un-archives it); a live one
			// is opened as-is.
			if newM, cmd, ok := m.openSelected(); ok {
				return newM, cmd
			}
		case "p":
			// Preview: open the selected session without changing its archived
			// state, so an archived session can be peeked at without restoring it.
			if len(m.entries) > 0 {
				m.result = Result{Action: ActionResume, Entry: m.entries[m.cursor]}
				return m, tea.Quit
			}
		}
		m.clampScroll()
		return m, cmd
	}
	// Forward everything else (notably the cursor-blink ticks) to the search box
	// while it is focused, so its cursor keeps blinking.
	if m.search.Focused() {
		var cmd tea.Cmd
		m.search, cmd = m.search.Update(msg)
		return m, cmd
	}
	return m, nil
}

// openSelected opens the highlighted session, restoring it first if archived.
// It reports ok=false (nothing to do) when the list is empty.
func (m *model) openSelected() (tea.Model, tea.Cmd, bool) {
	if len(m.entries) == 0 {
		return m, nil, false
	}
	e := m.entries[m.cursor]
	if e.Archived {
		_ = state.Unarchive(e.ID)
	}
	m.result = Result{Action: ActionResume, Entry: e}
	return m, tea.Quit, true
}

// stopSearch closes the search box and drops the filter, returning to the full
// list. Used by esc, ctrl+c, and clearing the input to empty.
func (m *model) stopSearch() {
	m.search.Blur()
	m.search.SetValue("")
	m.applyFilter()
	m.cursor = 0
	m.clampScroll()
}

// updateSearch handles keys while the search box is open. Navigation (enter,
// up/down) and exit keys (esc, ctrl+c) are handled here; every other key is
// forwarded to the textinput, which owns all the line-editing bindings
// (ctrl+w/u/a/e, word motions, space, paste, …). Clearing the input to empty
// also exits the search, per the same "empty means done" rule as esc.
func (m *model) updateSearch(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "ctrl+c", "esc":
		m.stopSearch()
		return m, nil
	case "enter":
		// Open the highlighted match; if nothing matches there is nothing to do.
		if newM, cmd, ok := m.openSelected(); ok {
			return newM, cmd
		}
		return m, nil
	case "up":
		if m.cursor > 0 {
			m.cursor--
		}
		m.clampScroll()
		return m, nil
	case "down":
		if m.cursor < len(m.entries)-1 {
			m.cursor++
		}
		m.clampScroll()
		return m, nil
	}

	before := m.search.Value()
	var cmd tea.Cmd
	m.search, cmd = m.search.Update(msg)
	after := m.search.Value()

	if before != "" && after == "" {
		m.stopSearch() // fully cleared the query -> leave search mode
		return m, nil
	}
	if before != after {
		m.applyFilter()
		m.cursor = 0
		m.clampScroll()
	}
	return m, cmd
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
		var msg string
		switch {
		case !m.loaded:
			msg = "Loading sessions…"
		case m.searchActive() && len(m.raw) > 0:
			msg = fmt.Sprintf("No titles match %q.", m.search.Value())
		case m.all:
			msg = "No sessions found."
		default:
			msg = "No sessions yet for this project."
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
		if m.isArchivedSectionStart(i) {
			b.WriteString(m.renderArchivedHeader(width))
			b.WriteString("\n")
		}
		b.WriteString(m.renderRow(i, m.entries[i], width))
		b.WriteString("\n")
	}
	b.WriteString(m.renderFooter(width))
	return b.String()
}

// isArchivedSectionStart reports whether entry i is the first archived entry, so
// the "Archived" divider should be drawn just before it.
func (m *model) isArchivedSectionStart(i int) bool {
	return m.entries[i].Archived && (i == 0 || !m.entries[i-1].Archived)
}

// archivedDividerHeight is how many lines the archived-section divider occupies:
// a blank line, the label rule, and another blank line so it stands well apart
// from the live sessions above it.
const archivedDividerHeight = 3

// renderArchivedHeader draws the (multi-line) divider that opens the archived
// section: padding above and below a full-width labelled rule.
func (m *model) renderArchivedHeader(width int) string {
	label := "── Archived "
	if pad := width - len([]rune(label)); pad > 0 {
		label += strings.Repeat("─", pad)
	}
	rule := archivedHeaderStyle.Render(truncate(label, width))
	return "\n" + rule + "\n"
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

// renderFooter renders the optional search line, the wrapped help text, and a
// position/summary line.
func (m *model) renderFooter(width int) string {
	var b strings.Builder
	if line := m.searchLine(width); line != "" {
		b.WriteString(line)
		b.WriteString("\n")
	}
	b.WriteString(helpStyle.Width(width).Render(m.helpText()))
	b.WriteString("\n")
	b.WriteString(dimStyle.Render(m.positionText()))
	return b.String()
}

// searchLine renders the textinput's "/query" prompt (with its live cursor). It
// returns "" when no search is in play.
func (m *model) searchLine(width int) string {
	if !m.searchActive() {
		return ""
	}
	if w := width - 1; w > 0 {
		m.search.Width = w
	}
	return m.search.View()
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
	isCurrent := e.ID != "" && e.ID == m.current

	// Line 1: selection bar + status dot + title. The current session (the one
	// open in the pane the picker was floated over) is underlined — "you are
	// here" — independently of the cursor.
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
	ts := titleStyle
	if selected {
		ts = selRowStyle
	}
	if isCurrent {
		ts = ts.Underline(true)
	}
	// Archived rows are tinted a muted grey so the live/archived split reads at a
	// glance, even while scrolled past the divider.
	if e.Archived {
		ts = ts.Foreground(archivedTint)
	}
	title = ts.Render(title)
	line1 := bar + dot + " " + title

	// Line 2: indented status/meta, continuing the selection bar.
	indent := "    "
	if selected {
		indent = selBar.Render("▌ ") + "  "
	}
	parts := []string{statusWord(e.Status)}
	// Remote sessions live in the project's rc window rather than one of their
	// own, so flag them: opening one lands on the remote-control server, not on a
	// pane showing the conversation.
	if e.Remote {
		parts = append(parts, "remote")
	}
	if m.all {
		parts = append(parts, filepath.Base(e.ProjectDir))
	}
	parts = append(parts, fmt.Sprintf("%d msg", e.Messages), relTime(e.Created))

	// A "this pane" tag flags the current session; reserve room for it so the
	// meta text truncates around it rather than overflowing the row.
	const tag = "this pane"
	metaW := width - 4
	if isCurrent {
		if metaW -= len(tag) + 3; metaW < 4 { // 3 = " · "
			metaW = 4
		}
	}
	ms := metaStyle
	if e.Archived {
		ms = archivedMetaStyle
	}
	meta := ms.Render(truncate(strings.Join(parts, " · "), metaW))
	if isCurrent {
		meta += ms.Render(" · ") + currentTag.Render(tag)
	}
	line2 := indent + meta

	return line1 + "\n" + line2
}

func (m *model) helpText() string {
	if m.search.Focused() {
		return "type to filter titles · ↑/↓ move · enter open · esc/ctrl+c cancel"
	}
	scope := "ctrl+a all"
	if m.all {
		scope = "ctrl+a this project"
	}
	return "↑/↓ move · enter open · / search · p preview · n new · x archive · " + scope + " · q cancel"
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
