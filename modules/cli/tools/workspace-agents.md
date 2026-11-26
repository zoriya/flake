# Workspaces

This only applies to this project. Elsewhere, work where you started and never create a
workspace or worktree.

You start in `default/`, the human's working copy — that is where the files they point you
at live, but it is not where you work. Every agent gets a jj workspace of its own beside
it, a sibling folder of `default/`.

Before editing anything, create yours and move into it. Name it after the task: one or two
words, three at the very most — kebab-case, under 16 characters (`fix-login`, `oauth-scope`,
`port-to-nix`). Take the name from the first thing you are asked to do; don't ask which
name to use, and don't rename it later.

If you have the `worktree_create` and `session_move` tools, use them: create the worktree
with your name, then move the session to the directory it returns. It is a jj workspace
starting from the state the human is working on. Once moved, your shell, reads, edits and
relative paths all happen in your workspace. If you are later told the working directory
changed back to `default/`, your workspace was deleted: create a new one the same way before
editing again.

Otherwise, create it by hand:

```sh
jj workspace add -r 'latest(::@ ~ empty())' ../<name>
cd ../<name>
```

`-r` is what starts you from the state the human is working on; without it your workspace
comes up empty. That revset picks the newest commit in `default@`'s history that actually
changes something: if they have uncommitted work it is `@` itself and you get it, and if
they are sitting on an empty working copy — the usual case — you branch off their last
real commit instead of stacking onto a placeholder.

That `cd` sticks, so every shell command after it — searching, building, testing, jj —
runs in your workspace. Reads and edits do not follow it: they take absolute paths, so
give them paths under your workspace.

Either way, the paths the human hands you, `@`-mentions included, point into `default/` —
read them there if you like, but edit the same relative path under your workspace instead.

`jj` in your own workspace is yours to run: `jj describe` your change as you go rather
than leaving it blank, in the style of the messages already in `jj log`. `default/` and
the other workspaces belong to someone else — you might read them but never write them, and
never run a jj command that rewrites their commits.

The human reviews your work while you are on it, by running `jj` directly in your
workspace: they insert a new empty commit right before your change and squash the parts
they have reviewed into it. So your stack can shift under you between two commands — your
change gained a parent you did not create, and `jj diff` shows less than you wrote, or
nothing at all. Nothing was lost: the files on disk are unchanged, the reviewed part just
lives one commit down now. Carry on in `@` as before. Don't re-apply the "missing" hunks,
don't undo, abandon, squash into or describe that parent — it is the human's. To see
everything you did, diff from below it (`jj diff --from <base>`), not just `@`.
