---
name: new-session
description: Spawn a separate Claude Code session to work on a described task, handing it a self-contained prompt built from the current conversation. Use when the user asks to "create/spawn/start a new session", "open a new claude for X", "hand this off to another session", or "do that in a separate session".
---

# New session

Spawn a fresh Claude Code session that works on what the user described,
in parallel with this one. It runs detached in the background and is
resumable like any other session, so the user picks it up when it is done.

## Steps

1. Work out the task and the project directory — the new session runs in
   whatever directory you launch it from, so `cd` there. Default to the
   current working directory. Only ask the user something if the task
   itself is ambiguous, not to confirm details you can read from the
   conversation or the repo.

2. Write the prompt to a file (the scratchpad dir if this session has one,
   otherwise `mktemp`). The new session shares **nothing** with this one
   and nobody is watching it work, so the prompt must stand on its own and
   must not ask questions back. Include, in plain prose:
   - the goal, stated as a concrete task;
   - the background from this conversation the new session would otherwise
     have to rediscover (what was tried, what failed, decisions already
     made and why);
   - the files that matter, as absolute or repo-relative paths — point at
     files rather than pasting large chunks of them;
   - constraints and non-goals: what must not change, what is out of scope;
   - how to know it worked (a command to run, a behaviour to check).

   Do not restate the user's global CLAUDE.md rules — the new session
   reads them itself. Write it as instructions to the new session, not as
   a summary of this conversation.

3. Launch it detached, with an id of your own so you can report it:

   ```sh
   id=$(uuidgen)
   setsid claude -p --session-id "$id" "$(cat /path/to/prompt.md)" >"/tmp/claude-$id.log" 2>&1 &
   echo "$id"
   ```

   `setsid` keeps it alive after the command returns, and it must be
   backgrounded — do not wait for it.

4. Tell the user, briefly, what the new session was told to do, and give
   them the session id (they resume it with `claude --resume <id>`, and it
   is in their session picker). Do not do the task yourself afterwards
   unless the user asks.
