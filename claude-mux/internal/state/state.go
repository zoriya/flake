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
