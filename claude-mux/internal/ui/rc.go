// This file renders the small floating popup shown by "claude-mux rc" (the C-x r
// chord): it displays whether a Claude remote-control (`claude rc`) server is
// running for the project, lets you toggle it on/off, and can jump to it.
package ui

import (
	"path/filepath"
	"strings"

	tea "github.com/charmbracelet/bubbletea"

	"claude-mux/internal/rc"
	"claude-mux/internal/tmux"
)

// RCAction is what the user chose to do when the rc popup closed.
type RCAction int

const (
	// RCActionNone means nothing further to do (closed, or toggled in place).
	RCActionNone RCAction = iota
	// RCActionSwitch means switch the client to the rc session.
	RCActionSwitch
)

// RCResult is the outcome of running the rc popup.
type RCResult struct {
	Action RCAction
}

type rcModel struct {
	dir     string
	srv     *tmux.Server
	running bool // rc session currently up
	enabled bool // persisted "enabled" flag
	err     error
	result  RCResult
	width   int
	height  int
}

// RunRCPopup shows the remote-control toggle popup for dir and returns the
// chosen action. Toggling is applied in place (it starts/stops the rc server and
// updates the persisted list); switching is deferred to the caller so it happens
// after the popup closes.
func RunRCPopup(dir string, srv *tmux.Server) (RCResult, error) {
	m := &rcModel{dir: dir, srv: srv}
	m.refresh()
	p := tea.NewProgram(m, tea.WithAltScreen())
	final, err := p.Run()
	if err != nil {
		return RCResult{}, err
	}
	return final.(*rcModel).result, nil
}

// refresh re-reads the live and persisted rc state for the project.
func (m *rcModel) refresh() {
	m.running = m.srv.HasRC(m.dir)
	m.enabled = rc.IsEnabled(m.dir)
}

// toggle flips rc on or off: starting/stopping the server and syncing the
// persisted enabled flag so it comes back automatically on the next cold start.
func (m *rcModel) toggle() {
	if m.running {
		m.err = m.srv.StopRC(m.dir)
		if m.err == nil {
			m.err = rc.Disable(m.dir)
		}
	} else {
		m.err = m.srv.StartRC(m.dir)
		if m.err == nil {
			m.err = rc.Enable(m.dir)
		}
	}
	m.refresh()
}

func (m *rcModel) Init() tea.Cmd { return nil }

func (m *rcModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width, m.height = msg.Width, msg.Height
	case tea.KeyMsg:
		switch msg.String() {
		case "ctrl+c", "q", "esc":
			return m, tea.Quit
		case "t", " ":
			m.toggle()
		case "s", "enter":
			if m.running {
				m.result = RCResult{Action: RCActionSwitch}
				return m, tea.Quit
			}
		case "r":
			m.refresh()
		}
	}
	return m, nil
}

func (m *rcModel) dims() (width int) {
	width = m.width
	if width <= 0 {
		width = 60
	}
	return
}

func (m *rcModel) View() string {
	width := m.dims()
	var b strings.Builder

	title := titleStyle.Render("Remote control") + dimStyle.Render(" · ") +
		dirStyle.Render(truncate(filepath.Base(m.dir), width-16))
	b.WriteString(title)
	b.WriteString("\n\n")

	// Status line: a dot + word describing whether rc is live.
	if m.running {
		b.WriteString(runningStyle.Render("● running"))
	} else {
		b.WriteString(closedStyle.Render("· stopped"))
	}
	// Note when the persisted flag disagrees with the live state (e.g. enabled
	// but not yet started, or running without being persisted).
	switch {
	case m.enabled && !m.running:
		b.WriteString(dimStyle.Render("  (enabled — will auto-start)"))
	case !m.enabled && m.running:
		b.WriteString(dimStyle.Render("  (not persisted)"))
	case m.enabled:
		b.WriteString(dimStyle.Render("  (auto-starts on launch)"))
	}
	b.WriteString("\n")

	if m.err != nil {
		b.WriteString("\n")
		b.WriteString(emptyStyle.Width(width).Render("error: " + m.err.Error()))
		b.WriteString("\n")
	}

	b.WriteString("\n")
	toggle := "t turn on"
	if m.running {
		toggle = "t turn off"
	}
	help := toggle + " · s switch to it · q close"
	b.WriteString(helpStyle.Width(width).Render(help))
	return b.String()
}
