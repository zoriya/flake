// Package state persists the runtime status a Claude session reports through
// hooks (running / questions / idle) so the picker can display it. Each session
// gets one small file named by its id under the state directory.
package state

import (
	"os"
	"path/filepath"
	"strings"

	"claude-mux/internal/paths"
)

func dir() string { return filepath.Join(paths.StateDir(), "status") }

func file(id string) string { return filepath.Join(dir(), id) }

// Set records status for the session id, overwriting any previous value.
func Set(id, status string) error {
	if id == "" {
		return nil
	}
	if err := os.MkdirAll(dir(), 0o755); err != nil {
		return err
	}
	return os.WriteFile(file(id), []byte(status), 0o644)
}

// Clear removes any recorded status for the session id.
func Clear(id string) error {
	if id == "" {
		return nil
	}
	err := os.Remove(file(id))
	if os.IsNotExist(err) {
		return nil
	}
	return err
}

// Get returns the recorded status word for id, or "" when none is recorded.
func Get(id string) string {
	b, err := os.ReadFile(file(id))
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(b))
}

// archiveDir is where the archived-session markers live: one empty file per
// archived session id. Membership is what matters, not the contents.
func archiveDir() string { return filepath.Join(paths.StateDir(), "archived") }

func archiveFile(id string) string { return filepath.Join(archiveDir(), id) }

// Archive marks the session id as archived so the picker files it away under the
// archived section instead of the live list.
func Archive(id string) error {
	if id == "" {
		return nil
	}
	if err := os.MkdirAll(archiveDir(), 0o755); err != nil {
		return err
	}
	return os.WriteFile(archiveFile(id), nil, 0o644)
}

// Unarchive removes the archived marker for the session id, returning it to the
// live list. It is a no-op when the session was not archived.
func Unarchive(id string) error {
	if id == "" {
		return nil
	}
	err := os.Remove(archiveFile(id))
	if os.IsNotExist(err) {
		return nil
	}
	return err
}

// ArchivedSet returns the set of archived session ids. Reading them all at once
// lets the caller enrich a whole listing without a stat per session.
func ArchivedSet() map[string]bool {
	entries, err := os.ReadDir(archiveDir())
	if err != nil {
		return nil
	}
	set := make(map[string]bool, len(entries))
	for _, e := range entries {
		if !e.IsDir() {
			set[e.Name()] = true
		}
	}
	return set
}
