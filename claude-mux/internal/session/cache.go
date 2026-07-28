package session

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sync"

	"claude-mux/internal/paths"
)

// The transcript listing is the picker's hot path: every "claude-mux list" is a
// fresh process (the C-x l popup) that would otherwise re-parse every transcript
// from scratch, and the picker reloads once a second while open. Transcripts are
// append-only, so a file whose size and modtime are unchanged parses to exactly
// what we saw last time. cache memoises parse() output keyed by (size, modtime)
// and persists it between runs, so a warm open only touches the handful of
// transcripts that actually changed.

// cachePath is where parsed transcript metadata is memoised between runs.
func cachePath() string {
	return filepath.Join(paths.CacheDir(), "sessions.json")
}

// cacheEntry is one memoised transcript: the parse result plus the file identity
// it was parsed from, so a changed file is detected and re-parsed.
type cacheEntry struct {
	Size    int64   `json:"size"`
	ModTime int64   `json:"mod"` // unix nanoseconds
	Session Session `json:"session"`
}

// cache is a process-local view of the on-disk memo, safe for the concurrent
// parsing in listDir.
type cache struct {
	mu      sync.Mutex
	entries map[string]cacheEntry // keyed by absolute transcript path
	dirty   bool
}

// loadCache reads the persisted memo. A missing or unreadable cache is not an
// error; it just means every transcript is a miss this run.
func loadCache() *cache {
	c := &cache{entries: map[string]cacheEntry{}}
	if data, err := os.ReadFile(cachePath()); err == nil {
		_ = json.Unmarshal(data, &c.entries)
	}
	return c
}

// get returns the memoised session for path when the file is unchanged since it
// was cached.
func (c *cache) get(path string, info os.FileInfo) (Session, bool) {
	c.mu.Lock()
	defer c.mu.Unlock()
	e, ok := c.entries[path]
	if !ok || e.Size != info.Size() || e.ModTime != info.ModTime().UnixNano() {
		return Session{}, false
	}
	return e.Session, true
}

// put records a freshly parsed session under its current file identity.
func (c *cache) put(path string, info os.FileInfo, s Session) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.entries[path] = cacheEntry{Size: info.Size(), ModTime: info.ModTime().UnixNano(), Session: s}
	c.dirty = true
}

// save writes the memo back atomically (temp file + rename). It is a no-op when
// nothing changed. Concurrent writers (two popups at once) use a pid-unique temp
// name and race only on the final rename, where last-writer-wins is harmless:
// the loser's fresh entries are simply re-parsed next time.
func (c *cache) save() {
	c.mu.Lock()
	defer c.mu.Unlock()
	if !c.dirty {
		return
	}
	data, err := json.Marshal(c.entries)
	if err != nil {
		return
	}
	if err := os.MkdirAll(paths.CacheDir(), 0o755); err != nil {
		return
	}
	tmp := fmt.Sprintf("%s.tmp.%d", cachePath(), os.Getpid())
	if err := os.WriteFile(tmp, data, 0o644); err != nil {
		return
	}
	if err := os.Rename(tmp, cachePath()); err != nil {
		_ = os.Remove(tmp)
	}
}
