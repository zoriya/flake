#!/usr/bin/env bash
# Convert the current repo into a workspace root: every workspace lives in a subfolder,
# the current one becoming `default`, and the root itself keeps an empty working copy
# (jj's stand-in for a bare repo — https://github.com/jj-vcs/jj/discussions/9137) so jj
# commands still work there.

set -euo pipefail
shopt -s dotglob nullglob

root="$JJ_WORKSPACE_ROOT"
[[ -e $root/.wsp-root || ! -e $root/../.wsp-root ]] || root=$(dirname "$root")
cd "$root"

if [[ -e .wsp-root ]]; then
	ln -sfn "$claude_md" CLAUDE.md
	echo "$root is already a workspace root" >&2
	echo "$root/default"
	exit 0
fi
if [[ ! -d .jj/repo ]]; then
	echo "$root is not the main workspace" >&2
	exit 1
fi

current=$(jj log -r @ --no-graph --color=never -T 'change_id')
jj workspace rename root
jj workspace add -r @ ./default
jj new -r 'root()'
jj -R default edit "$current"

for f in *; do
	case "$f" in .jj | .git | .gitignore | .envrc | default) continue ;; esac
	if [[ -d "$f" && -d "default/$f" ]]; then
		cp -a "$f/." "default/$f/"
		rm -rf "$f"
	else
		mv "$f" default/
	fi
done
printf '*\n' > .gitignore


if [[ -e .envrc ]]; then
	if [[ -e default/flake.nix ]]; then
		printf 'use flake path:./default\n' > .envrc
	elif [[ -e default/shell.nix ]]; then
		printf 'use nix ./default/shell.nix\n' > .envrc
	fi
fi

touch .wsp-root
ln -sfn "$claude_md" CLAUDE.md
echo "$root/default"
