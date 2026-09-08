// Package workspace deals with jj workspace projects: repos converted with
// `jj workspace-init`, where the root keeps an empty working copy plus a
// `.wsp-root` marker and every real working copy is a subfolder of it
// (`default` being the human's, and where sessions start).
//
// Agents make their own: the CLAUDE.md `jj workspace-init` leaves in the project
// root tells each one to `jj workspace add` a workspace named after its task and
// work there, so they edit files nobody else is editing while sharing one repo.
// claude-mux only has to find them (Peers), keep them under one tmux session
// (Host), and take them down again (Remove).
package workspace

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// marker is the file identifying a workspace-root project.
const marker = ".wsp-root"

// Root returns the workspace-root project directory dir belongs to — the
// nearest directory at or above it holding the .wsp-root marker — or "" when
// dir has nothing to do with such a project.
//
// It walks the whole way up because a directory can sit anywhere inside a
// workspace, not just at its top: an editor opened on a subfolder, a shell cd'd
// into one, an agent working there. Looking only at dir and its parent made
// every one of those look like a project of its own — its own tmux session, its
// own empty session list — instead of part of the project it is in.
func Root(dir string) string {
	if dir == "" {
		return ""
	}
	for d := filepath.Clean(dir); ; {
		if _, err := os.Stat(filepath.Join(d, marker)); err == nil {
			return d
		}
		parent := filepath.Dir(d)
		if parent == d { // hit the filesystem root
			return ""
		}
		d = parent
	}
}

// Peers lists the directories a project's sessions can live in: every workspace
// under the root — `default`, where they start, and the agents' own, where a
// reopened one may be running — plus the root itself, which older sessions were
// launched in. For anything that is not a workspace project it is just [dir],
// so callers can use it unconditionally.
func Peers(dir string) []string {
	root := Root(dir)
	if root == "" {
		return []string{dir}
	}
	dirs := []string{root}
	entries, err := os.ReadDir(root)
	if err != nil {
		return dirs
	}
	for _, e := range entries {
		if !e.IsDir() {
			continue
		}
		// A workspace is a directory with its own working copy state.
		p := filepath.Join(root, e.Name())
		if _, err := os.Stat(filepath.Join(p, ".jj")); err != nil {
			continue
		}
		dirs = append(dirs, p)
	}
	return dirs
}

// Host returns the directory that identifies dir's project — the root for a
// workspace project, so every workspace of it shares one tmux session and one
// session list no matter which one a command is run from. Non-workspace
// directories identify themselves.
func Host(dir string) string {
	if root := Root(dir); root != "" {
		return root
	}
	return dir
}

// Work returns the directory to start Claude in: `default`, the human's working
// copy, so the files they point at (an `@`-mention in the first prompt, say)
// resolve without a prefix. The agent creates its own workspace beside it and
// cds there; `--add-dir` on the project root is what lets it write there.
func Work(dir string) string {
	root := Root(dir)
	if root == "" {
		return dir
	}
	def := filepath.Join(root, "default")
	if _, err := os.Stat(def); err != nil {
		// No `default` (renamed, or removed after its work was merged): the root
		// is still a working copy of its own, so fall back to it rather than
		// starting Claude in a directory that isn't there.
		return root
	}
	return def
}

// Remove deletes an agent's workspace and its directory.
//
// It snapshots the working copy first, from inside the workspace: jj only
// records files when a command runs there, and once the directory is gone
// nothing ever will again. With the snapshot, everything the agent touched is
// in its working-copy commit, which `jj workspace forget` leaves behind in the
// repo (`jj log -r 'all()'` still shows it) — so removing a workspace throws
// away the checkout, never the work. Without it, jj would forget the working
// copy as it last saw it (empty) and the changes would go with the directory,
// which is why a failed snapshot aborts the removal.
//
// Files jj does not track — anything gitignored, build output, .env — are not
// in any change and do go with the directory.
func Remove(wsDir string) error {
	wsDir = filepath.Clean(wsDir)
	root := Root(wsDir)
	// Only ever an agent's own workspace: a direct child of the root, so a
	// subfolder someone happened to be sitting in (a session's recorded cwd is
	// wherever it ran) can never stand in for the workspace containing it; never
	// the project root, which would leave the repo without the working copy jj
	// needs there; and never `default`, which is the human's. All three are one
	// bad caller away otherwise, and this is a delete.
	if root == "" || filepath.Dir(wsDir) != root || filepath.Base(wsDir) == "default" {
		return fmt.Errorf("%s is not an agent's workspace", wsDir)
	}
	snap := exec.Command("jj", "status")
	snap.Dir = wsDir
	if out, err := snap.CombinedOutput(); err != nil {
		return fmt.Errorf("jj status in %s: %s", wsDir, strings.TrimSpace(string(out)))
	}
	// The forget has to run from a working copy that is staying — the project
	// root is not one, and the workspace being removed is about to stop being one.
	from := sibling(wsDir)
	if from == "" {
		return fmt.Errorf("no other workspace to run `jj workspace forget` from")
	}
	forget := exec.Command("jj", "workspace", "forget", filepath.Base(wsDir))
	forget.Dir = from
	if out, err := forget.CombinedOutput(); err != nil {
		return fmt.Errorf("jj workspace forget: %s", strings.TrimSpace(string(out)))
	}
	return os.RemoveAll(wsDir)
}

// sibling returns another workspace of wsDir's project to run repo commands
// from, preferring `default`, or "" when wsDir is the only one left.
func sibling(wsDir string) string {
	if def := filepath.Join(Root(wsDir), "default"); def != wsDir {
		if _, err := os.Stat(filepath.Join(def, ".jj")); err == nil {
			return def
		}
	}
	for _, p := range Peers(wsDir) {
		if p == wsDir || p == Root(wsDir) {
			continue
		}
		return p
	}
	return ""
}
