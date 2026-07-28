// Package session reads Claude Code's on-disk transcripts and turns them into a
// listing of sessions for a given project directory.
package session

import (
	"bufio"
	"encoding/json"
	"io"
	"os"
	"path/filepath"
	"runtime"
	"sort"
	"strings"
	"sync"
	"time"

	"claude-mux/internal/paths"
)

// Status describes the live state of a Claude session.
type Status int

const (
	// StatusClosed means the session is not open in any window (transcript only).
	StatusClosed Status = iota
	// StatusIdle means the session is open and waiting for input (at rest).
	StatusIdle
	// StatusRunning means Claude is actively working on a response.
	StatusRunning
	// StatusQuestions means Claude is waiting for the user to answer something.
	StatusQuestions
)

func (s Status) String() string {
	switch s {
	case StatusRunning:
		return "running"
	case StatusQuestions:
		return "questions"
	case StatusIdle:
		return "idle"
	default:
		return "closed"
	}
}

// Open reports whether the session is open in a window (any non-closed state).
func (s Status) Open() bool { return s != StatusClosed }

// ParseStatus maps a status word (as written by the hook) to an open Status,
// defaulting to StatusIdle for anything unrecognised.
func ParseStatus(word string) Status {
	switch word {
	case "running":
		return StatusRunning
	case "questions", "question", "waiting":
		return StatusQuestions
	default:
		return StatusIdle
	}
}

// Session is a single Claude conversation transcript.
type Session struct {
	ID         string    // transcript uuid (filename without extension)
	Path       string    // absolute path to the .jsonl transcript
	Title      string    // human friendly title
	CWD        string    // working directory recorded in the transcript
	Updated    time.Time // timestamp of the most recent activity
	Created    time.Time // timestamp of the first activity
	Messages   int       // number of user/assistant messages
	Status     Status    // running/idle, populated by the caller
	RunningPID int       // pid of the process holding it open, when running
}

// line is the subset of a transcript record we care about. Decoding only these
// fields keeps parsing cheap even for large transcripts.
type line struct {
	Type       string    `json:"type"`
	AiTitle    string    `json:"aiTitle"`
	LastPrompt string    `json:"lastPrompt"`
	Summary    string    `json:"summary"`
	CWD        string    `json:"cwd"`
	Timestamp  time.Time `json:"timestamp"`
}

// List returns every Claude session recorded for projectDir, most recently
// active first. Status is left as StatusIdle; callers layer that on top.
func List(projectDir string) ([]Session, error) {
	c := loadCache()
	sessions, err := listDir(paths.SessionDir(projectDir), c)
	if err != nil {
		return nil, err
	}
	c.save()
	sortByRecent(sessions)
	return sessions, nil
}

// ListAll returns every Claude session across every project, most recently
// active first. Each session's CWD (read from the transcript) identifies which
// project it belongs to.
func ListAll() ([]Session, error) {
	projects, err := os.ReadDir(paths.ProjectsDir())
	if err != nil {
		if os.IsNotExist(err) {
			return nil, nil
		}
		return nil, err
	}
	c := loadCache()
	var all []Session
	for _, p := range projects {
		if !p.IsDir() {
			continue
		}
		sessions, err := listDir(filepath.Join(paths.ProjectsDir(), p.Name()), c)
		if err != nil {
			continue
		}
		all = append(all, sessions...)
	}
	c.save()
	sortByRecent(all)
	return all, nil
}

// listDir parses every *.jsonl transcript directly inside dir. Unchanged
// transcripts are served from the cache; the rest are parsed concurrently, so
// the cost scales with what actually changed rather than the whole history.
func listDir(dir string, c *cache) ([]Session, error) {
	entries, err := os.ReadDir(dir)
	if err != nil {
		if os.IsNotExist(err) {
			return nil, nil
		}
		return nil, err
	}

	var (
		files []string
		infos []os.FileInfo
	)
	for _, e := range entries {
		if e.IsDir() || !strings.HasSuffix(e.Name(), ".jsonl") {
			continue
		}
		info, err := e.Info()
		if err != nil {
			continue
		}
		files = append(files, filepath.Join(dir, e.Name()))
		infos = append(infos, info)
	}

	results := make([]Session, len(files))
	ok := make([]bool, len(files))
	sem := make(chan struct{}, runtime.NumCPU())
	var wg sync.WaitGroup
	for i := range files {
		if s, hit := c.get(files[i], infos[i]); hit {
			results[i], ok[i] = s, true
			continue
		}
		wg.Add(1)
		sem <- struct{}{}
		go func(i int) {
			defer wg.Done()
			defer func() { <-sem }()
			s, err := parse(files[i])
			if err != nil {
				return // skip unreadable/corrupt transcripts rather than fail the whole list
			}
			c.put(files[i], infos[i], s)
			results[i], ok[i] = s, true
		}(i)
	}
	wg.Wait()

	sessions := make([]Session, 0, len(files))
	for i := range results {
		if ok[i] {
			sessions = append(sessions, results[i])
		}
	}
	return sessions, nil
}

func sortByRecent(sessions []Session) {
	sort.Slice(sessions, func(i, j int) bool {
		return sessions[i].Updated.After(sessions[j].Updated)
	})
}

// parse reads a single transcript, extracting metadata for the listing.
func parse(path string) (Session, error) {
	f, err := os.Open(path)
	if err != nil {
		return Session{}, err
	}
	defer f.Close()

	info, _ := f.Stat()
	s := Session{
		ID:   strings.TrimSuffix(filepath.Base(path), ".jsonl"),
		Path: path,
	}
	if info != nil {
		s.Updated = info.ModTime()
	}

	var aiTitle, lastPrompt, summary string

	sc := bufio.NewScanner(f)
	// Transcript lines can be long (embedded content); grow the buffer.
	sc.Buffer(make([]byte, 0, 64*1024), 8*1024*1024)
	for sc.Scan() {
		raw := sc.Bytes()
		if len(raw) == 0 {
			continue
		}
		var l line
		if err := json.Unmarshal(raw, &l); err != nil {
			continue
		}
		switch l.Type {
		case "ai-title":
			if l.AiTitle != "" {
				aiTitle = l.AiTitle
			}
		case "last-prompt":
			if l.LastPrompt != "" {
				lastPrompt = l.LastPrompt
			}
		case "summary":
			if l.Summary != "" {
				summary = l.Summary
			}
		case "user", "assistant":
			s.Messages++
		}
		if l.CWD != "" && s.CWD == "" {
			s.CWD = l.CWD
		}
		if !l.Timestamp.IsZero() {
			if s.Created.IsZero() || l.Timestamp.Before(s.Created) {
				s.Created = l.Timestamp
			}
			if l.Timestamp.After(s.Updated) {
				s.Updated = l.Timestamp
			}
		}
	}
	if err := sc.Err(); err != nil && err != io.EOF {
		return Session{}, err
	}

	s.Title = firstNonEmpty(aiTitle, summary, firstLine(lastPrompt), "(untitled)")
	return s, nil
}

func firstNonEmpty(vals ...string) string {
	for _, v := range vals {
		if strings.TrimSpace(v) != "" {
			return strings.TrimSpace(v)
		}
	}
	return ""
}

// firstLine returns the first non-empty line of s, collapsed to single spaces.
func firstLine(s string) string {
	for _, ln := range strings.Split(s, "\n") {
		ln = strings.TrimSpace(ln)
		if ln != "" {
			return strings.Join(strings.Fields(ln), " ")
		}
	}
	return ""
}
