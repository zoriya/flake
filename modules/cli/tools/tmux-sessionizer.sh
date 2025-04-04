#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
	selected=$1
else
	selected=$(find ~/projects ~/work -mindepth 1 -maxdepth 1 -type d | fzf)
fi

if [[ -z $selected ]]; then
	exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
	tmux new-session -s "$selected_name" -c "$selected"
	exit 0
fi

current_session=$(tmux display-message -p "#S")

if ! tmux has-session "-t=$selected_name" 2> /dev/null; then
	tmux new-session -ds "$selected_name" -c "$selected" -e "CMD=$EDITOR ."
	tmux new-window -dt "$selected_name:1" -c "$selected" -e "CMD="
fi

tmux switch-client -t "$selected_name"

if [[ "$current_session" == \#* ]]; then
	tmux kill-session -t "$current_session"
fi
