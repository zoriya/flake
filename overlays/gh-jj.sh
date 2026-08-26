if [ -z "$GIT_DIR" ] && ! git rev-parse --git-dir >/dev/null 2>&1 &&
  store=$(jj git root 2>/dev/null); then
  # that store is bare and its HEAD is stale, so gh would report the wrong
  # branch. Give it a worktree-style GIT_DIR instead: refs and objects come from
  # the store via commondir, HEAD is ours and names the bookmark @ is on.
  branch=$(jj log --ignore-working-copy --no-graph -r 'latest(::@ & bookmarks())' \
    -T 'local_bookmarks.map(|b| b.name()).join("\n")' 2>/dev/null | head -1)
  [ -n "$branch" ] ||
    branch="jj/$(jj log --ignore-working-copy --no-graph -r @ -T 'change_id.short()' 2>/dev/null)"
  GIT_DIR="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/gh-jj-$(id -u)/${store//\//%}"
  if mkdir -p "$GIT_DIR" &&
    printf '%s\n' "$store" >"$GIT_DIR/commondir" &&
    printf 'ref: refs/heads/%s\n' "$branch" >"$GIT_DIR/HEAD"; then
    export GIT_DIR
  else
    unset GIT_DIR
  fi
fi
