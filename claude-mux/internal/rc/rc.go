// Package rc persists which project directories have a Claude remote-control
// (`claude rc`) server enabled. The list lets claude-mux bring every enabled
// project's rc server back up automatically when the isolated server first
// starts.
package rc

import (
	"bufio"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"claude-mux/internal/paths"
)

// listPath is the file holding the newline-separated absolute project
// directories that have rc enabled.
func listPath() string {
	return filepath.Join(paths.StateDir(), "rc-projects")
}

// List returns the project directories with rc enabled, in stable order.
func List() []string {
	f, err := os.Open(listPath())
	if err != nil {
		return nil
	}
	defer f.Close()

	var dirs []string
	seen := make(map[string]bool)
	sc := bufio.NewScanner(f)
	for sc.Scan() {
		dir := strings.TrimSpace(sc.Text())
		if dir == "" || seen[dir] {
			continue
		}
		seen[dir] = true
		dirs = append(dirs, dir)
	}
	return dirs
}

// IsEnabled reports whether rc is enabled for dir.
func IsEnabled(dir string) bool {
	for _, d := range List() {
		if d == dir {
			return true
		}
	}
	return false
}

// Enable records dir as rc-enabled (no-op if already present).
func Enable(dir string) error {
	dirs := List()
	for _, d := range dirs {
		if d == dir {
			return nil
		}
	}
	return write(append(dirs, dir))
}

// Disable removes dir from the rc-enabled list (no-op if absent).
func Disable(dir string) error {
	dirs := List()
	kept := dirs[:0]
	for _, d := range dirs {
		if d != dir {
			kept = append(kept, d)
		}
	}
	return write(kept)
}

// write persists the (deduplicated, sorted) directory list.
func write(dirs []string) error {
	if err := os.MkdirAll(paths.StateDir(), 0o755); err != nil {
		return err
	}
	uniq := make([]string, 0, len(dirs))
	seen := make(map[string]bool)
	for _, d := range dirs {
		if d == "" || seen[d] {
			continue
		}
		seen[d] = true
		uniq = append(uniq, d)
	}
	sort.Strings(uniq)
	data := strings.Join(uniq, "\n")
	if data != "" {
		data += "\n"
	}
	return os.WriteFile(listPath(), []byte(data), 0o644)
}
