# Workspaces

You start in `default/`, the human's working copy — that is where the files they point you
at live, but it is not where you work. Every agent gets a jj workspace of its own beside
it, a sibling folder of `default/`.

Before editing anything, create yours and move into it:

```sh
jj workspace add -r 'latest(::@ ~ empty())' ../<name>
cd ../<name>
```

`-r` is what starts you from the state the human is working on; without it your workspace
comes up empty. That revset picks the newest commit in `default@`'s history that actually
changes something: if they have uncommitted work it is `@` itself and you get it, and if
they are sitting on an empty working copy — the usual case — you branch off their last
real commit instead of stacking onto a placeholder. Name it after the task: one or two
words, three at the very most — kebab-case, under 16 characters (`fix-login`, `oauth-scope`,
`port-to-nix`). Take the name from the first thing you are asked to do; don't ask which
name to use, and don't rename it later.

That `cd` sticks, so every shell command after it — searching, building, testing, jj —
runs in your workspace. Reads and edits do not follow it: they take absolute paths, so
give them paths under your workspace. The paths the human hands you, `@`-mentions
included, point into `default/` — read them there if you like, but edit the same relative
path under your workspace instead.

`jj` in your own workspace is yours to run: `jj describe` your change as you go rather
than leaving it blank, in the style of the messages already in `jj log`. `default/` and
the other workspaces belong to someone else — you might read them but never write them, and
never run a jj command that rewrites their commits.
