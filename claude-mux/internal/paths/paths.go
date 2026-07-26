// Package paths resolves the on-disk locations claude-mux depends on: Claude's
// config/session storage and claude-mux's own cache/config files.
package paths

import (
	"os"
	"path/filepath"
	"strings"
)

// ClaudeConfigDir returns the directory Claude Code stores its state in.
// It mirrors Claude Code's own resolution order: $CLAUDE_CONFIG_DIR wins,
// then $XDG_CONFIG_HOME/claude, then ~/.claude.
func ClaudeConfigDir() string {
	if d := os.Getenv("CLAUDE_CONFIG_DIR"); d != "" {
		return d
	}
	if xdg := os.Getenv("XDG_CONFIG_HOME"); xdg != "" {
		return filepath.Join(xdg, "claude")
	}
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".claude")
}

// ProjectsDir is where Claude keeps per-project session transcripts.
func ProjectsDir() string {
	return filepath.Join(ClaudeConfigDir(), "projects")
}

// EncodeProjectPath converts an absolute filesystem path into the directory
// name Claude uses under projects/. Claude replaces every character that is not
// an ASCII letter or digit with a dash, e.g. /home/me/projects/flake ->
// -home-me-projects-flake.
func EncodeProjectPath(dir string) string {
	var b strings.Builder
	b.Grow(len(dir))
	for _, r := range dir {
		if (r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z') || (r >= '0' && r <= '9') {
			b.WriteRune(r)
		} else {
			b.WriteRune('-')
		}
	}
	return b.String()
}

// SessionDir returns the directory holding transcripts for the given project
// directory.
func SessionDir(projectDir string) string {
	return filepath.Join(ProjectsDir(), EncodeProjectPath(projectDir))
}

// CacheDir is where claude-mux writes generated files (the tmux config).
func CacheDir() string {
	if xdg := os.Getenv("XDG_CACHE_HOME"); xdg != "" {
		return filepath.Join(xdg, "claude-mux")
	}
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".cache", "claude-mux")
}

// StateDir is where claude-mux keeps per-session runtime state (the status a
// Claude session reports through hooks).
func StateDir() string {
	if xdg := os.Getenv("XDG_STATE_HOME"); xdg != "" {
		return filepath.Join(xdg, "claude-mux")
	}
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".local", "state", "claude-mux")
}
