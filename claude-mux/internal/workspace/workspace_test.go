package workspace

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

// project lays out a workspace-root project — the .wsp-root marker plus a
// `default` and an agent workspace, each with a .jj so Peers sees them.
func project(t *testing.T) string {
	t.Helper()
	root := t.TempDir()
	if err := os.WriteFile(filepath.Join(root, marker), nil, 0o644); err != nil {
		t.Fatal(err)
	}
	for _, ws := range []string{"default", "agent"} {
		if err := os.MkdirAll(filepath.Join(root, ws, ".jj"), 0o755); err != nil {
			t.Fatal(err)
		}
	}
	return root
}

func TestRootFromAnyDepth(t *testing.T) {
	root := project(t)
	deep := filepath.Join(root, "agent", "modules", "cli")
	if err := os.MkdirAll(deep, 0o755); err != nil {
		t.Fatal(err)
	}
	for _, dir := range []string{root, filepath.Join(root, "default"), filepath.Join(root, "agent"), deep} {
		if got := Root(dir); got != root {
			t.Errorf("Root(%s) = %q, want %q", dir, got, root)
		}
		if got := Host(dir); got != root {
			t.Errorf("Host(%s) = %q, want %q", dir, got, root)
		}
	}
	// Nothing above an ordinary directory carries the marker.
	plain := t.TempDir()
	if got := Root(plain); got != "" {
		t.Errorf("Root(%s) = %q, want \"\"", plain, got)
	}
	if got := Host(plain); got != plain {
		t.Errorf("Host(%s) = %q, want %q", plain, got, plain)
	}
}

// Remove is a delete, and Root now resolving from any depth means the guard has
// to reject a subfolder of a workspace as well as the root and `default`.
func TestRemoveRejectsAnythingButAnAgentWorkspace(t *testing.T) {
	root := project(t)
	sub := filepath.Join(root, "agent", "modules")
	if err := os.MkdirAll(sub, 0o755); err != nil {
		t.Fatal(err)
	}
	for _, dir := range []string{root, filepath.Join(root, "default"), sub, t.TempDir()} {
		err := Remove(dir)
		if err == nil || !strings.Contains(err.Error(), "not an agent's workspace") {
			t.Errorf("Remove(%s) = %v, want a refusal", dir, err)
		}
		if _, statErr := os.Stat(dir); statErr != nil {
			t.Errorf("Remove(%s) deleted it anyway", dir)
		}
	}
}
