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
| `C-x n` | Start a fresh Claude session in a new window (instant — see below) |
| `C-x u` | Float the current Claude usage (limits) for this project          |
| `C-x d` | Detach — everything keeps running in the background               |
| `C-x C-x` | Send a literal `C-x` through to Claude                           |

The inner tmux loads **none** of your personal tmux config and binds nothing but
the keys above, so from inside it feels like you are talking to `claude` directly.

When a Claude session ends (you quit `claude`), claude-mux **detaches** and drops
you back to your shell. Any other sessions keep running in the background and can
be reattached (`claude-mux`) or reopened from the picker. To actually terminate
running sessions, use `claude-mux kill`. In the picker, `x` archives a session
(closing it if it is still running) and files it under the archived section.

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
Sessions are listed in the order they were created (oldest first) so a session
keeps its place regardless of its status or recent activity. Archived sessions
(see `x` below) are grouped at the bottom under an **Archived** divider, in the
same creation order.

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
| `enter`        | Open the selected session (restores it if archived) |
| `/`            | Search: filter the list by title as you type    |
| `p`            | Preview: open without restoring an archived session |
| `n`            | Start a fresh session                           |
| `x`            | Archive the selected session (deletes its jj workspace) |
| `ctrl+a`       | Toggle between this project and **all** projects |
| `q` / `esc`    | Cancel                                          |

Selecting a session that is already running just jumps to its window; selecting an
idle one resumes it (`claude --resume`) in a new window. Opening an archived
session with `enter` also restores it out of the archived section; `p` opens it
the same way but leaves it archived, so you can peek without restoring. Press `/`
to filter the list to sessions whose title matches what you type — the box has the
usual line-editing keys (`ctrl+w`/`ctrl+u`, word motions, `ctrl+a`/`ctrl+e`, …),
`↑`/`↓` still move the selection, and `enter` opens the highlighted match.
`esc`, `ctrl+c`, or clearing the box back to empty leaves the search. With `ctrl+a` (or
`claude-mux list --all`) the picker shows sessions from every project, labelled by
project; resuming one there opens (or switches to) that project's session.

### Usage (`C-x u`)

`C-x u` floats a pane showing your current Claude usage — session and weekly
limits with their progress bars, plus what is driving them. It renders Claude's
interactive `/usage` panel (the pretty, coloured one) off-screen in a throwaway
tmux pane and snapshots it, so you get the real view without a full session
lingering. Press `q` (or `esc` / `ctrl+c`) to close it. If the interactive
render is unavailable it falls back to the plain-text `claude -p /usage` report.

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
(so it never spawns a stray Claude window) and records the project in an
**rc-enabled list**. Toggling it off kills that session and removes the project
from the list.

Sessions you create from the phone or the browser are spawned *inside* that one
`claude rc` process, so they never get a tmux window of their own. The picker
finds them by their reported status instead of by a window tag, and tags their
row `· remote`. Opening one resumes it in a window of its own (`claude --resume`)
rather than switching to the rc window, which hosts the remote-control server and
so shows none of the conversation. `x` on a remote session only archives it — it
does not kill the window, which would take the whole remote-control endpoint down
with it.

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

### Instant new sessions (`C-x n`)

`claude` takes a moment to cold-start, which made `C-x n` feel sluggish. To hide
that, claude-mux keeps a **warm pool**: one pre-booted, idle Claude session per
project, sitting in its own hidden background tmux session (never shown in the
picker). `C-x n` just hands that pre-booted window over — instantly, no
cold-start — and boots a replacement into the pool in the background so the next
`C-x n` is ready too. The pool is filled on attach, so even the first `C-x n` is
instant. If the pool is drained (a burst of new windows), `C-x n` falls back to a
normal cold start and refills afterwards.

A warm session writes no transcript until it is actually used, so idle warm
sessions never pollute your history or the picker. If a warm Claude exits on its
own it is left as a dead pane (so it can never detach your client) and reaped on
the next fill.

### One jj workspace per agent

In a project converted with `jj workspace-init` — the repo root keeps an empty
working copy plus a `.wsp-root` marker, and every real working copy is a
subfolder of it, `default` being the one you work in — **each agent works in a jj
workspace of its own, and names it itself**. `jj workspace-init` leaves a
`CLAUDE.md` in the project root telling every agent to `jj workspace add -r
'latest(::@ ~ empty())' ../<name>` and `cd` there before touching anything, so
the directory is named after the task (`fix-login`) rather than after a session
id — and so it branches off the newest commit that actually changes something
rather than the empty working copy `default` usually sits on. That CLAUDE.md is a
symlink to the guide home-manager installs (`~/.config/jj/workspace-CLAUDE.md`),
never a copy, so rewording it updates every converted project at once; roots made
before a change to the layout catch up by running `jj workspace-init` again,
which only relinks. The root's `.gitignore` is `*`, so the CLAUDE.md never shows
up as a change in the repo, and Claude picks it up from there for every workspace
below it.

The root's own workspace is named `root`. It exists so `jj` works at the root at
all (there is no bare repo in jj — an empty working copy is the stand-in) and is
never somewhere to work, so the nvim and jjui workspace pickers skip it.

Sessions launch in **`default`**, the human's working copy, so a path in the
first prompt — an `@`-mention especially — resolves without a prefix. The agent
then creates its workspace beside it and `cd`s in, which sticks for every shell
command after it. Claude refuses to edit outside the directory it was started in,
so claude-mux passes `--add-dir <project root>` for workspace projects; that one
flag is what lets the agent write in the workspace it just made.

The project is identified by its **root**, not by `default`: `claude-mux` run
from any workspace resolves to the same project, so its windows stay in one tmux
session and its sessions in one picker. Ordinary projects are untouched — no
CLAUDE.md, no flag, sessions run in the project directory as before.

All of a project's workspaces share **one** tmux session and one window list, so
`C-x l` lists every agent of the project regardless of which workspace it works
in — each row tagged with its workspace name — and `C-x n` always starts in the
project you launched from.

claude-mux learns which workspace a session made **from the transcript**: `jj
workspace add` announces `Created workspace in "…"`, Claude records the tool
output verbatim, and the session parser reads it back. Nothing has to be
registered, no hook fires, the agent needs no extra permission, and it works
retroactively for sessions that already ran. The picker tags each row with that
workspace name.

Archiving a session with `x` then **deletes its workspace**. The working copy is
snapshotted first, so everything the agent did is recorded in a jj change that
stays in the repo (`jj log` still shows it) — the checkout goes, the work does
not. Files jj does not track (gitignored build output, `.env`, …) are not in any
change and do go with the directory. The transcript is left alone, so the
conversation stays in the list and can be reopened.

## How it works

- **Sessions** are read straight from Claude's transcript storage
  (`$CLAUDE_CONFIG_DIR/projects/<encoded-cwd>/<uuid>.jsonl`), so the list is
  authoritative regardless of what is open in tmux.
- **Running status** is tracked by launching every window through
  `claude-mux run`, which assigns a known session id (`claude --session-id`) and
  records it as a tmux window option (`@claude_session_id`). That id is what lets
  the picker tell a live session apart and jump straight to its window. Claude's
  live session id can drift from the one baked in at launch — `/clear`, in-app
  `/resume` and context compaction each mint a fresh id in the same window — so
  the status hook re-tags its own window with the id it reports, keeping the tag
  pointed at the session that is actually running there.
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
claude-mux usage      Show the current Claude usage/limits (used by the C-x u chord)
claude-mux new        Start a fresh Claude session in the current directory
claude-mux kill       Kill the running sessions for the current directory
claude-mux kill --all Kill every running session across all projects
claude-mux reload     Repoint a running server's chords at this binary (live)
claude-mux run        Internal launcher used by the tmux windows
```

## Build

```sh
go build -o claude-mux .
```

In this flake it is packaged as `pkgs.claude-mux` (see `overlays/default.nix`) and
installed via `modules/cli/home.nix`.
