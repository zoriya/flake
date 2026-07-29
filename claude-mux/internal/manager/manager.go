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
	// Archived is true when the user has archived this session; archived sessions
	// are grouped at the bottom of the listing under their own header.
	Archived bool
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
	archived := state.ArchivedSet()  // id -> archived

	entries := make([]Entry, 0, len(sessions))
	for _, s := range sessions {
		e := Entry{Session: s, ProjectDir: projectDirOf(s, dir), Archived: archived[s.ID]}
		if target, ok := running[s.ID]; ok {
			// Open in a window; the substate (running/questions/idle) comes from
			// what the session last reported through its hooks.
			e.Status = session.ParseStatus(state.Get(s.ID))
			// No hook fires when a response is interrupted with Esc, so the hook
			// status can be left stuck at "running". If the transcript's last
			// entry is an interrupt marker, the session is actually idle.
			if s.Interrupted && e.Status != session.StatusIdle {
				e.Status = session.StatusIdle
			}
			e.Target = target
		} else {
			e.Status = session.StatusClosed
		}
		entries = append(entries, e)
	}

	// Order strictly by creation: live sessions first (newest created first), then
	// archived sessions in the same creation order. Status and recent activity do
	// not affect placement, so a session never jumps around as it runs or idles.
	sort.SliceStable(entries, func(i, j int) bool {
		if entries[i].Archived != entries[j].Archived {
			return !entries[i].Archived // live sessions before archived ones
		}
		return entries[i].Created.After(entries[j].Created)
	})
	return entries, nil
}

// projectDirOf returns the directory a session belongs to, preferring the cwd
// recorded in its transcript and falling back to the queried dir.
func projectDirOf(s session.Session, dir string) string {
	if s.CWD != "" {
		return s.CWD
	}
	return dir
}
