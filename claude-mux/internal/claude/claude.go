// Package claude touches Claude Code's own config file (.claude.json) for the
// narrow bits claude-mux needs to launch `claude rc` non-interactively.
package claude

import (
	"encoding/json"
	"os"
	"path/filepath"

	"claude-mux/internal/paths"
)

// configJSONPath is Claude Code's per-user state file.
func configJSONPath() string {
	return filepath.Join(paths.ClaudeConfigDir(), ".claude.json")
}

// EnsureTrusted marks dir as workspace-trusted in Claude's .claude.json.
//
// Claude refuses to start `claude rc` in a directory whose trust dialog has not
// been accepted (it errors with "Workspace not trusted" and exits), and there is
// no global setting or flag to skip that dialog — per-project
// `hasTrustDialogAccepted` is the only mechanism. Enabling remote control for a
// project through claude-mux is an explicit decision to trust it, so we record
// that here.
//
// It is a no-op (no write at all) when the directory is already trusted, which
// keeps it out of the way of Claude's own frequent writes to this file in the
// common case; only the first enable of a never-trusted project writes.
func EnsureTrusted(dir string) error {
	path := configJSONPath()

	data, err := os.ReadFile(path)
	if os.IsNotExist(err) {
		data = []byte("{}")
	} else if err != nil {
		return err
	}

	// Preserve every top-level key (and every per-project key) verbatim by
	// keeping them as raw JSON; only the one trust flag is touched.
	var root map[string]json.RawMessage
	if err := json.Unmarshal(data, &root); err != nil {
		return err
	}
	if root == nil {
		root = map[string]json.RawMessage{}
	}

	var projects map[string]map[string]json.RawMessage
	if raw, ok := root["projects"]; ok {
		if err := json.Unmarshal(raw, &projects); err != nil {
			return err
		}
	}
	if projects == nil {
		projects = map[string]map[string]json.RawMessage{}
	}

	proj := projects[dir]
	if proj == nil {
		proj = map[string]json.RawMessage{}
	}
	if v, ok := proj["hasTrustDialogAccepted"]; ok && string(v) == "true" {
		return nil // already trusted: nothing to write (and no race with Claude)
	}
	proj["hasTrustDialogAccepted"] = json.RawMessage("true")
	projects[dir] = proj

	projRaw, err := json.Marshal(projects)
	if err != nil {
		return err
	}
	root["projects"] = projRaw

	out, err := json.MarshalIndent(root, "", "  ")
	if err != nil {
		return err
	}
	// Write atomically so a concurrent Claude reader never sees a half-file.
	tmp := path + ".claude-mux.tmp"
	if err := os.WriteFile(tmp, out, 0o644); err != nil {
		return err
	}
	return os.Rename(tmp, path)
}
