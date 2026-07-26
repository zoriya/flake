# claude-mux

WARNING: this is vibe coded slop

A tiny tmux-backed session manager for [Claude Code](https://claude.com/claude-code).

`claude-mux` runs an **isolated tmux server** (its own socket) whose only job is
to host `claude` processes. Because it uses a dedicated socket, it nests cleanly
inside another tmux session without any binding or session conflict — that is the
whole point of the separate socket.

## Usage

```sh
cd ~/projects/my-thing
claude-mux
```

This starts (or re-attaches) the Claude session for the current directory. Inside
a session there are exactly two chords plus a detach, under the `C-x` prefix:

| Key     | Action                                                             |
| ------- | ----------------------------------------------------------------- |
| `C-x l` | Float a picker of **every** Claude session for this project       |
| `C-x r` | Float the remote-control (`claude rc`) toggle for this project     |
| `C-x n` | Start a fresh Claude session in a new window (current keeps going) |
| `C-x d` | Detach — everything keeps running in the background               |
| `C-x C-x` | Send a literal `C-x` through to Claude                           |

The inner tmux loads **none** of your personal tmux config and binds nothing but
the keys above, so from inside it feels like you are talking to `claude` directly.

When a Claude session ends (you quit `claude`), claude-mux **detaches** and drops
you back to your shell. Any other sessions keep running in the background and can
be reattached (`claude-mux`) or reopened from the picker. To actually terminate
sessions, use `claude-mux kill` or `x` in the picker.

### The session picker (`C-x l`)

The picker lists every Claude session recorded for the current project directory —
not just the ones currently open in a window. Brand-new sessions that have not
exchanged any messages yet are omitted. The list scrolls when it is longer than
the popup, and the popup follows your terminal's light/dark theme. For each
session it shows:

- a status glyph:
  - **●** green — *running* (Claude is working),
  - **⬤** amber — *waiting for you* (Claude asked something / needs attention),
  - **⬤** blue — *open* (idle in a window, ready for input),
  - **◯** dim — *closed* (transcript only, not open in any window);
- the session title (Claude's AI-generated title, falling back to the last prompt),
- the message count and how long ago it was last active.

Each session is shown on two lines (title, then status/meta) so it stays readable
in narrow popups, and the list and help text scroll/wrap to fit small windows.
Sessions needing attention float to the top (waiting → running → open → closed).

The session you opened the picker from — the one running in the pane the popup is
floating over — is marked "you are here": its title is underlined and its meta
line carries a green `· this pane` tag. This is independent of the cursor, so you
can always see where you came from even after moving the selection or when the
list reorders.

While the picker is open it reloads itself once a second, so statuses, titles and
message counts stay live automatically; the highlighted session is tracked
by id so the cursor stays on it even when the list reorders.

The live states (running / waiting / open) are reported by Claude Code hooks
(`claude-mux hook --status …`), wired up in `modules/cli/home.nix`.

| Key            | Action                                          |
| -------------- | ----------------------------------------------- |
| `↑`/`↓`, `j`/`k` | Move the selection                            |
| `enter`        | Open the selected session                       |
| `n`            | Start a fresh session                           |
| `x`            | Kill the selected running session               |
| `ctrl+a`       | Toggle between this project and **all** projects |
| `q` / `esc`    | Cancel                                          |

Selecting a session that is already running just jumps to its window; selecting an
idle one resumes it (`claude --resume`) in a new window. With `ctrl+a` (or
`claude-mux list --all`) the picker shows sessions from every project, labelled by
project; resuming one there opens (or switches to) that project's session.

### Remote control (`C-x r`)

[`claude rc`](https://claude.com/claude-code) (remote-control) runs a persistent
server that lets you drive local sessions from claude.ai/code or the Claude mobile
app. `C-x r` floats a small popup to manage it **per project**:

| Key         | Action                                            |
| ----------- | ------------------------------------------------- |
| `t` / space | Toggle the rc server on/off for this project      |
| `s` / enter | Switch the client to the running rc session       |
| `q` / `esc` | Close the popup                                   |

Toggling it on starts `claude rc` in its own dedicated, background tmux session
(so it never spawns a stray Claude window and never clutters the `C-x l` picker)
and records the project in an **rc-enabled list**. Toggling it off kills that
session and removes the project from the list.

`claude rc` is launched non-interactively so it never stalls the background
session on a prompt: it runs with `--spawn=same-dir` (skipping the spawn-mode
chooser), and the project is pre-trusted in Claude's `.claude.json`
(`hasTrustDialogAccepted`) so it does not block on the workspace trust dialog.
Enabling remote control for a project is itself the decision to trust it — there
is no global setting to skip that dialog, so claude-mux records it per project.

The enabled list is persisted (under the state dir, `rc-projects`). Whenever the
isolated tmux server first cold-starts, claude-mux automatically brings the rc
server back up for **every** rc-enabled project, so your remote-control endpoints
are always available without having to open each project by hand.

## How it works

- **Sessions** are read straight from Claude's transcript storage
  (`$CLAUDE_CONFIG_DIR/projects/<encoded-cwd>/<uuid>.jsonl`), so the list is
  authoritative regardless of what is open in tmux.
- **Running status** is tracked by launching every window through
  `claude-mux run`, which assigns a known session id (`claude --session-id`) and
  records it as a tmux window option (`@claude_session_id`). That id is what lets
  the picker tell a live session apart and jump straight to its window.
- Each project directory gets its own tmux session on the shared socket, named
  after the directory (basename + a short path hash).

## Configuration

| Variable            | Meaning                                              | Default      |
| ------------------- | ---------------------------------------------------- | ------------ |
| `CLAUDE_MUX_SOCKET` | tmux socket name for the isolated server             | `claude-mux` |
| `CLAUDE_CONFIG_DIR` | Claude's config dir (where transcripts live)         | Claude's default |

## Commands

```
claude-mux            Start or attach the session for the current directory
claude-mux list       Interactive session picker (used by the C-x l chord)
claude-mux list --all   Picker across every project (also toggled with ctrl+a)
claude-mux list --dump  Print the session listing as plain text (scripting/debug)
claude-mux rc         Remote-control toggle popup (used by the C-x r chord)
claude-mux new        Start a fresh Claude session in the current directory
claude-mux kill       Kill the running sessions for the current directory
claude-mux kill --all Kill every running session across all projects
claude-mux run        Internal launcher used by the tmux windows
```

## Build

```sh
go build -o claude-mux .
```

In this flake it is packaged as `pkgs.claude-mux` (see `overlays/default.nix`) and
installed via `modules/cli/home.nix`.
