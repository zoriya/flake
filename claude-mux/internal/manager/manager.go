// Package manager ties transcript listing and the isolated tmux server together
// into a single enriched view used by the picker and the CLI.
package manager

import (
	"os"
	"sort"

	"claude-mux/internal/session"
	"claude-mux/internal/state"
	"claude-mux/internal/tmux"
	"claude-mux/internal/workspace"
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
	// Remote is true when the session is hosted by the project's remote-control
	// server, i.e. it was created from the mobile app or claude.ai/code rather
	// than in a window of its own.
	Remote bool
}

// Dir is the tree this session's files are in: the jj workspace its agent made
// for itself, when it made one and the checkout is still there, and otherwise
// the directory the session itself runs in (`default`, for a workspace project).
// It is what the picker points the editor at (see tmux.NotifyCwd), so a deleted
// workspace falls back rather than sending anyone into a directory that is gone.
func (e Entry) Dir() string {
	if e.Workspace != "" {
		if fi, err := os.Stat(e.Workspace); err == nil && fi.IsDir() {
			return e.Workspace
		}
	}
	return e.ProjectDir
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
		if err != nil {
			return nil, err
		}
	} else {
		// A project converted with `jj workspace-init` keeps its code in workspace
		// subfolders, and each agent works in one of its own — so its sessions are
		// filed under the workspace, not the project. They all belong to the same
		// project, so list every workspace's sessions together. For an ordinary
		// directory Peers is just [dir].
		var firstErr error
		for _, d := range workspace.Peers(dir) {
			s, listErr := session.List(d)
			if listErr != nil {
				// One unreadable workspace shouldn't blank the whole list, but a
				// listing that found nothing at all should say why.
				if firstErr == nil {
					firstErr = listErr
				}
				continue
			}
			sessions = append(sessions, s...)
		}
		if len(sessions) == 0 && firstErr != nil {
			return nil, firstErr
		}
	}

	live := srv.Live()              // what the isolated server is hosting
	status := state.LiveSet()       // id -> status word, for every live session
	archived := state.ArchivedSet() // id -> archived

	entries := make([]Entry, 0, len(sessions))
	for _, s := range sessions {
		e := Entry{Session: s, ProjectDir: projectDirOf(s, dir), Archived: archived[s.ID]}
		w, hosted := live.Windows[s.ID]
		st, reported := status[s.ID]
		switch {
		// Open in a window; the substate (running/questions/idle) comes from what
		// the session last reported through its hooks. A remote-control window is
		// only trusted while its session is still reporting: nothing untags it when
		// the session ends, so a stale tag would otherwise read as open forever.
		case hosted && (!w.RC || reported):
			e.Status = session.ParseStatus(st)
			// No hook fires when a response is interrupted with Esc, so the hook
			// status can be left stuck at "running". If the transcript's last
			// entry is an interrupt marker, the session is actually idle.
			if s.Interrupted && e.Status != session.StatusIdle {
				e.Status = session.StatusIdle
			}
			e.Target, e.Remote = w.Target, w.RC
		// Sessions created from the mobile app or claude.ai/code are spawned inside
		// the project's `claude rc` process, so they never get a window of their own
		// and used to read as closed even while actively working. Their hooks do
		// report status, so a live status plus a running rc server for the project
		// is what marks them open. Target is the rc window purely so the picker can
		// see where they are hosted — opening one resumes it in a window of its own
		// (see cmdList), because the rc window shows the server, not the session.
		case reported && live.RC[e.ProjectDir] != "":
			e.Status = session.ParseStatus(st)
			e.Target, e.Remote = live.RC[e.ProjectDir], true
		default:
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
