// Package manager ties transcript listing and the isolated tmux server together
// into a single enriched view used by the picker and the CLI.
package manager

import (
	"sort"

	"claude-mux/internal/session"
	"claude-mux/internal/state"
	"claude-mux/internal/tmux"
)

// Entry is a session augmented with its live tmux location, when running.
type Entry struct {
	session.Session
	// Target is the tmux "session:window" hosting this session, empty when the
	// session is not currently open in the isolated server.
	Target string
	// ProjectDir is the directory this session belongs to (its own cwd), used to
	// resume it in the right project even when listing across all projects.
	ProjectDir string
}

// Load lists sessions and marks which are currently running by consulting the
// tmux windows that claude-mux tagged with their session id. When all is true it
// spans every project; otherwise it is scoped to dir. Brand-new sessions that
// have not written a transcript yet are intentionally omitted.
func Load(dir string, all bool, srv *tmux.Server) ([]Entry, error) {
	var (
		sessions []session.Session
		err      error
	)
	if all {
		sessions, err = session.ListAll()
	} else {
		sessions, err = session.List(dir)
	}
	if err != nil {
		return nil, err
	}

	running := srv.RunningSessions() // id -> target ("slug:window")

	entries := make([]Entry, 0, len(sessions))
	for _, s := range sessions {
		e := Entry{Session: s, ProjectDir: projectDirOf(s, dir)}
		if target, ok := running[s.ID]; ok {
			// Open in a window; the substate (running/questions/idle) comes from
			// what the session last reported through its hooks.
			e.Status = session.ParseStatus(state.Get(s.ID))
			e.Target = target
		} else {
			e.Status = session.StatusClosed
		}
		entries = append(entries, e)
	}

	// Order by attention: questions first, then running, idle, closed; then by
	// most recent activity within each group.
	sort.SliceStable(entries, func(i, j int) bool {
		pi, pj := statusRank(entries[i].Status), statusRank(entries[j].Status)
		if pi != pj {
			return pi > pj
		}
		return entries[i].Updated.After(entries[j].Updated)
	})
	return entries, nil
}

// statusRank orders statuses so the ones needing attention float to the top.
func statusRank(s session.Status) int {
	switch s {
	case session.StatusQuestions:
		return 3
	case session.StatusRunning:
		return 2
	case session.StatusIdle:
		return 1
	default: // closed
		return 0
	}
}

// projectDirOf returns the directory a session belongs to, preferring the cwd
// recorded in its transcript and falling back to the queried dir.
func projectDirOf(s session.Session, dir string) string {
	if s.CWD != "" {
		return s.CWD
	}
	return dir
}
