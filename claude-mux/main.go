// Command claude-mux is a tmux-backed session manager for Claude Code. It runs
// an isolated tmux server (its own socket, so it nests cleanly inside another
// tmux) whose only purpose is to host `claude` processes, with two chords:
//
//	C-x l   float a picker of every Claude session for the project
//	C-x r   toggle a persistent `claude rc` (remote-control) server for the project
//	C-x n   start a fresh Claude session in a new window
//	C-x u   float the current Claude usage (limits) for the project
//
// See README.md for the full picture.
package main

import (
	"bufio"
	"crypto/rand"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"

	"github.com/charmbracelet/x/term"

	"claude-mux/internal/manager"
	"claude-mux/internal/rc"
	"claude-mux/internal/state"
	"claude-mux/internal/tmux"
	"claude-mux/internal/ui"
)

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, "claude-mux:", err)
		os.Exit(1)
	}
}

func run(args []string) error {
	if len(args) > 0 {
		switch args[0] {
		case "list":
			return cmdList(args[1:])
		case "rc":
			return cmdRC(args[1:])
		case "new":
			return cmdNew(args[1:])
		case "run":
			return cmdRun(args[1:])
		case "usage":
			return cmdUsage(args[1:])
		case "kill":
			return cmdKill(args[1:])
		case "reload":
			return cmdReload(args[1:])
		case "hook":
			return cmdHook(args[1:])
		case "-h", "--help", "help":
			usage()
			return nil
		}
	}
	return cmdAttach()
}

func usage() {
	fmt.Print(`claude-mux - a tmux-backed session manager for Claude Code

Usage:
  claude-mux            Start or attach the Claude session for the current directory
  claude-mux list       Show the interactive session picker (used by the C-x l chord)
  claude-mux new        Start a fresh Claude session in the current directory
  claude-mux kill       Kill the running sessions for the current directory
  claude-mux kill --all Kill every running session across all projects
  claude-mux reload     Repoint a running server's chords at this binary (live)

Inside a session:
  C-x l   list every Claude session for this project
  C-x r   toggle a persistent remote-control (claude rc) server for this project
  C-x n   new Claude session in a background window
  C-x u   show the current Claude usage (limits) in a floating pane
  C-x d   detach (everything keeps running)

In the picker: enter open · / search titles · n new · x kill selected · ctrl+a all · q cancel
In the rc popup: t toggle · s switch to it · q close

Environment:
  CLAUDE_MUX_SOCKET   tmux socket name (default "claude-mux")
  CLAUDE_CONFIG_DIR   Claude's config dir (session transcripts live here)
`)
}

// cmdAttach starts/attaches the isolated tmux session for the current directory.
func cmdAttach() error {
	dir, err := os.Getwd()
	if err != nil {
		return err
	}
	srv := tmux.New()
	if srv.InsideOurServer() {
		return fmt.Errorf("already inside a claude-mux session (use C-x n for a new session, C-x d to detach)")
	}
	// A cold start (the server was not already running) is when we bring every
	// rc-enabled project's remote-control server back up in the background.
	coldStart := !srv.IsRunning()
	slug, err := srv.EnsureSession(dir)
	if err != nil {
		return err
	}
	if coldStart {
		for _, p := range rc.List() {
			_ = srv.StartRC(p)
		}
	}
	// Pin this client's home project (the dir it was launched from) keyed by its
	// tty, so C-x n always creates a session here even after the client is later
	// switched onto another project's session by resuming a cross-project session
	// from the picker. The client's tty is the terminal claude-mux is attached to,
	// i.e. our own stdin — the same tty tmux reports as #{client_tty}.
	srv.SetClientHome(ttyName(), dir)
	return srv.Attach(slug)
}

// ttyName returns the path of the terminal on this process's stdin (e.g.
// "/dev/pts/3"), which is the tty the tmux client we attach will run on and thus
// matches tmux's #{client_tty}. Returns "" when stdin is not a terminal.
func ttyName() string {
	if name, err := os.Readlink("/proc/self/fd/0"); err == nil {
		return name
	}
	return ""
}

// cmdRun is the launcher every Claude window goes through. It settles on a
// session id (a fresh uuid, or the one being resumed), records it on the tmux
// window so the picker can find this session later, then execs Claude.
func cmdRun(args []string) error {
	fs := flag.NewFlagSet("run", flag.ContinueOnError)
	dirFlag := fs.String("dir", "", "project directory (defaults to cwd)")
	resumeFlag := fs.String("resume", "", "resume this session id instead of starting fresh")
	sessionFlag := fs.String("session-id", "", "start a fresh session with this exact id (defaults to a random one)")
	if err := fs.Parse(args); err != nil {
		return err
	}
	dir := resolveDir(*dirFlag)

	// Precedence: resume an existing id, else a caller-supplied fresh id (used by
	// the warm pool, which pre-generates the id so it can hand the window over),
	// else a fresh random one.
	id := *resumeFlag
	if id == "" {
		id = *sessionFlag
	}
	if id == "" {
		id = genUUID()
	}
	srv := tmux.New()
	if pane := os.Getenv("TMUX_PANE"); pane != "" && srv.InsideOurServer() {
		_ = srv.TagWindow(pane, id)
	}

	if *resumeFlag != "" {
		return execIn(dir, "claude", "--resume", id)
	}
	return execIn(dir, "claude", "--session-id", id)
}

// cmdKill terminates running sessions: those for the current project, or every
// project with --all. Transcripts (history) are left untouched.
func cmdKill(args []string) error {
	fs := flag.NewFlagSet("kill", flag.ContinueOnError)
	dirFlag := fs.String("dir", "", "project directory (defaults to cwd)")
	all := fs.Bool("all", false, "kill running sessions across all projects")
	if err := fs.Parse(args); err != nil {
		return err
	}
	srv := tmux.New()
	if *all {
		if err := srv.KillAll(); err != nil {
			return err
		}
		fmt.Println("killed all claude-mux sessions")
		return nil
	}
	dir := resolveDir(*dirFlag)
	killed, err := srv.KillProject(dir)
	if err != nil {
		return err
	}
	if killed {
		fmt.Printf("killed running sessions for %s\n", dir)
	} else {
		fmt.Printf("no running sessions for %s\n", dir)
	}
	return nil
}

// cmdReload regenerates the isolated tmux config from this binary and re-sources
// it into the running server, so its chords (C-x l/r/n/u) run the current
// claude-mux rather than the store path baked in when the server first started.
// It is meant to be run by home-manager activation after a Nix rebuild: the live
// server's bindings hot-reload to the new binary while every running Claude
// window keeps going untouched. It is a quiet no-op when no server is running.
func cmdReload(args []string) error {
	fs := flag.NewFlagSet("reload", flag.ContinueOnError)
	sockFlag := fs.String("socket", "", "tmux socket name")
	if err := fs.Parse(args); err != nil {
		return err
	}
	if *sockFlag != "" {
		os.Setenv("CLAUDE_MUX_SOCKET", *sockFlag)
	}
	reloaded, err := tmux.New().Reload()
	if err != nil {
		return err
	}
	if reloaded {
		fmt.Println("reloaded claude-mux bindings")
	}
	return nil
}

// cmdHook is invoked by Claude Code hooks to record a session's live status. It
// reads the hook JSON payload from stdin (for the session id) and writes the
// status where the picker can read it. It prints nothing so it is safe to wire
// into stdout-sensitive hooks like UserPromptSubmit.
func cmdHook(args []string) error {
	fs := flag.NewFlagSet("hook", flag.ContinueOnError)
	status := fs.String("status", "", "status to record: running|questions|idle|closed")
	if err := fs.Parse(args); err != nil {
		return err
	}
	var payload struct {
		SessionID string `json:"session_id"`
		Message   string `json:"message"`
	}
	if data, err := io.ReadAll(os.Stdin); err == nil && len(data) > 0 {
		_ = json.Unmarshal(data, &payload)
	}
	if payload.SessionID == "" {
		return nil // nothing we can key on; do not fail the hook
	}

	st := *status
	// Claude's Notification hook fires both for genuine prompts (permission /
	// questions) and for the plain "you've been idle" timeout. The latter must
	// not masquerade as "waiting for you", so treat an idle-waiting notification
	// as idle rather than questions.
	if st == "questions" && isIdleNotification(payload.Message) {
		st = "idle"
	}

	if st == "closed" {
		return state.Clear(payload.SessionID)
	}

	// Keep the hosting tmux window's session-id tag in sync with the id Claude is
	// actually reporting. claude-mux tags a window with the id it launched (see
	// cmdRun), but Claude's live session id diverges from that whenever a new id
	// is minted in the same window — /clear, in-app /resume, context compaction.
	// Left alone, the window would point at a dead id (the picker shows it "open"
	// and its real, running state — keyed to the new id — has no window, so it
	// reads as closed). Re-tagging on every hook self-heals that: the window now
	// carries the live id, and the id it used to host is no longer live here, so
	// its stale state is cleared rather than left to accumulate.
	//
	// Only the Claude that *owns* the pane may retag it. A Claude started from
	// inside another one (a `claude -p` run from a Bash tool, say) inherits its
	// TMUX_PANE, and would otherwise steal the tag from the session actually
	// running in that window — dropping it to "closed" in the picker until its
	// next hook fires. Claude exports CLAUDE_PID to its children, so the hook can
	// tell the two apart: for a window claude-mux launched the pane command execs
	// Claude, so the pane's pid is the owning Claude's pid.
	if pane := os.Getenv("TMUX_PANE"); pane != "" {
		srv := tmux.New()
		if srv.InsideOurServer() && os.Getenv("CLAUDE_PID") == srv.PanePID(pane) {
			if old := srv.WindowSessionID(pane); old != "" && old != payload.SessionID {
				_ = state.Clear(old)
			}
			_ = srv.TagWindow(pane, payload.SessionID)
		}
	}

	return state.Set(payload.SessionID, st)
}

// isIdleNotification reports whether a Notification hook message is the idle
// timeout ("Claude is waiting for your input …") rather than a real prompt for
// permission or an answer. Only the idle case must not surface as attention.
func isIdleNotification(msg string) bool {
	return strings.Contains(strings.ToLower(msg), "waiting for your input")
}

// cmdNew starts a fresh Claude session: a new window when inside the server,
// otherwise plain `claude` for standalone use.
func cmdNew(args []string) error {
	fs := flag.NewFlagSet("new", flag.ContinueOnError)
	dirFlag := fs.String("dir", "", "project directory (defaults to cwd)")
	sockFlag := fs.String("socket", "", "tmux socket name")
	clientFlag := fs.String("client", "", "tty of the invoking client, to resolve its home project")
	if err := fs.Parse(args); err != nil {
		return err
	}
	if *sockFlag != "" {
		os.Setenv("CLAUDE_MUX_SOCKET", *sockFlag)
	}
	dir := resolveDir(*dirFlag)
	srv := tmux.New()
	// Prefer the invoking client's pinned home project over --dir: --dir carries
	// #{@claude_project_dir}, which follows the client's current session and so
	// points at the wrong project once it has been switched onto a cross-project
	// session. The home is the dir the client was launched from (see SetClientHome).
	if home := srv.ClientHome(*clientFlag); home != "" {
		dir = home
	}
	if srv.InsideOurServer() {
		return srv.NewWindowFresh(dir)
	}
	return execClaude(dir)
}

// cmdUsage renders the current Claude usage into the floating pane opened by
// the C-x u chord. It snapshots Claude's interactive `/usage` panel — the one
// with the coloured progress bars — by rendering it in a throwaway off-screen
// tmux pane sized to this popup and printing the captured screen verbatim. It
// then blocks until the user presses q (or Esc / Ctrl-C) so the popup stays up
// to be read instead of closing the instant the command exits.
//
// If the interactive render is unavailable (no tmux, or it times out) it falls
// back to the plain-text `claude -p /usage` report so something still shows.
func cmdUsage(args []string) error {
	fs := flag.NewFlagSet("usage", flag.ContinueOnError)
	dirFlag := fs.String("dir", "", "project directory (defaults to cwd)")
	if err := fs.Parse(args); err != nil {
		return err
	}
	dir := resolveDir(*dirFlag)

	// Reserve the bottom row for the "press q" hint so it never scrolls the top
	// of the panel out of view.
	cols, rows := 80, 24
	if w, h, err := term.GetSize(os.Stdout.Fd()); err == nil && w > 0 && h > 0 {
		cols, rows = w, h
	}
	renderRows := rows - 1
	if renderRows < 8 {
		renderRows = rows
	}

	if screen, err := tmux.CaptureUsage(dir, cols, renderRows); err == nil && strings.Contains(screen, "% used") {
		os.Stdout.WriteString(screen)
	} else {
		cmd := exec.Command("claude", "-p", "/usage")
		cmd.Dir = dir
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if runErr := cmd.Run(); runErr != nil {
			fmt.Fprintln(os.Stderr, "\nfailed to fetch usage:", runErr)
		}
	}

	fmt.Print("\n\x1b[2m─── press q to close ───\x1b[0m")
	waitForQuit()
	return nil
}

// waitForQuit blocks until the user presses q/Q, Esc or Ctrl-C. It puts the
// terminal in raw mode so a single keypress is enough; if raw mode is
// unavailable (stdin is not a tty) it falls back to reading a line.
func waitForQuit() {
	fd := os.Stdin.Fd()
	old, err := term.MakeRaw(fd)
	if err != nil {
		bufio.NewReader(os.Stdin).ReadString('\n')
		return
	}
	defer term.Restore(fd, old)

	buf := make([]byte, 1)
	for {
		n, err := os.Stdin.Read(buf)
		if err != nil || n == 0 {
			return
		}
		switch buf[0] {
		case 'q', 'Q', 3, 27: // q, Q, Ctrl-C, Esc
			return
		}
	}
}

// cmdList runs the picker and carries out the chosen action.
func cmdList(args []string) error {
	fs := flag.NewFlagSet("list", flag.ContinueOnError)
	dirFlag := fs.String("dir", "", "project directory (defaults to cwd)")
	sockFlag := fs.String("socket", "", "tmux socket name")
	all := fs.Bool("all", false, "list sessions across all projects, not just this one")
	dump := fs.Bool("dump", false, "print sessions as plain text instead of the interactive picker")
	if err := fs.Parse(args); err != nil {
		return err
	}
	if *sockFlag != "" {
		os.Setenv("CLAUDE_MUX_SOCKET", *sockFlag)
	}
	dir := resolveDir(*dirFlag)
	srv := tmux.New()

	if *dump {
		return dumpList(dir, *all, srv)
	}

	res, err := ui.RunPicker(dir, *all, srv)
	if err != nil {
		return err
	}

	switch res.Action {
	case ui.ActionNew:
		if srv.InsideOurServer() {
			return srv.NewWindowFresh(dir) // "new" always lands in the current project
		}
		return execClaude(dir)
	case ui.ActionResume:
		e := res.Entry
		pdir := e.ProjectDir
		if pdir == "" {
			pdir = dir
		}
		if srv.InsideOurServer() {
			if e.Target != "" { // already open in a window: just jump to it
				return srv.Focus(e.Target)
			}
			return srv.ResumeInProject(pdir, e.ID)
		}
		return execClaudeResume(pdir, e.ID)
	}
	return nil // cancelled
}

// cmdRC runs the remote-control toggle popup (the C-x r chord) and, when the
// user asked for it, switches the client to the rc session afterwards.
func cmdRC(args []string) error {
	fs := flag.NewFlagSet("rc", flag.ContinueOnError)
	dirFlag := fs.String("dir", "", "project directory (defaults to cwd)")
	sockFlag := fs.String("socket", "", "tmux socket name")
	if err := fs.Parse(args); err != nil {
		return err
	}
	if *sockFlag != "" {
		os.Setenv("CLAUDE_MUX_SOCKET", *sockFlag)
	}
	dir := resolveDir(*dirFlag)
	srv := tmux.New()

	res, err := ui.RunRCPopup(dir, srv)
	if err != nil {
		return err
	}
	if res.Action == ui.RCActionSwitch {
		return srv.FocusRC(dir)
	}
	return nil
}

// dumpList prints the enriched session listing as plain text (non-interactive).
func dumpList(dir string, all bool, srv *tmux.Server) error {
	entries, err := manager.Load(dir, all, srv)
	if err != nil {
		return err
	}
	fmt.Printf("%d session(s) for %s\n", len(entries), dir)
	for _, e := range entries {
		target := e.Target
		if target == "" {
			target = "-"
		}
		fmt.Printf("  [%-7s] %-40.40s  %2d msg  %s  pane=%s  %s\n",
			e.Status, e.Title, e.Messages, e.Updated.Format("2006-01-02 15:04"), target, e.ID)
	}
	return nil
}

// resolveDir returns an absolute project directory. It prefers the given value,
// then $CLAUDE_MUX_PROJECT_DIR (set on the tmux session, so the popup resolves
// the right project), then the current working directory.
func resolveDir(dir string) string {
	if dir == "" {
		dir = os.Getenv("CLAUDE_MUX_PROJECT_DIR")
	}
	if dir == "" {
		if wd, err := os.Getwd(); err == nil {
			return wd
		}
		return "."
	}
	if abs, err := filepath.Abs(dir); err == nil {
		return abs
	}
	return dir
}

// execClaude replaces the process with a fresh `claude` running in dir.
func execClaude(dir string) error {
	return execIn(dir, "claude")
}

// execClaudeResume replaces the process with `claude --resume id` in dir.
func execClaudeResume(dir, id string) error {
	return execIn(dir, "claude", "--resume", id)
}

// genUUID returns a random RFC 4122 v4 UUID for a new Claude session id.
func genUUID() string {
	var b [16]byte
	if _, err := rand.Read(b[:]); err != nil {
		// crypto/rand should not fail; fall back to a time-free but unique-ish id.
		return fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:16])
	}
	b[6] = (b[6] & 0x0f) | 0x40 // version 4
	b[8] = (b[8] & 0x3f) | 0x80 // variant 10
	return fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:16])
}

func execIn(dir string, name string, args ...string) error {
	bin, err := exec.LookPath(name)
	if err != nil {
		return err
	}
	if err := os.Chdir(dir); err != nil {
		return err
	}
	return syscall.Exec(bin, append([]string{name}, args...), os.Environ())
}
