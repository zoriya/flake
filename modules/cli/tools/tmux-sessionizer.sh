#!/usr/bin/env bash

slots_dir="${XDG_DATA_HOME:-$HOME/.local/share}/tmux-sessionizer/slots"

pick_project() {
	find ~/projects ~/work -mindepth 1 -maxdepth 1 -type d | fzf
}

case "$1" in
	--slot)
		slot_file="$slots_dir/$2"
		if [[ -s "$slot_file" ]]; then
			selected=$(<"$slot_file")
		else
			tmux display-message "tmux-sessionizer: slot '$2' is unbound (use prefix + C-${2^^} to set it)"
			exit 0
		fi
		;;
	--set)
		selected=$(pick_project)
		[[ -z $selected ]] && exit 0
		mkdir -p "$slots_dir"
		printf '%s\n' "$selected" > "$slots_dir/$2"
		tmux display-message "tmux-sessionizer: bound slot '$2' -> $selected"
		;;
	"")
		selected=$(pick_project)
		;;
	*)
		selected=$1
		;;
esac

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
	if [[ "$selected" == "$HOME/work/new" ]]; then
		selected_name="work"
		ssh_tunnel="ssh zroux@localhost -p 2222 -D 6666"
		tmux new-session -ds "$selected_name" -c "$selected" -e "CMD=$ssh_tunnel"
	else
		tmux new-session -ds "$selected_name" -c "$selected" -e "CMD=$EDITOR ."
		tmux new-window -dt "$selected_name:1" -c "$selected" -e "CMD="
	fi
fi

tmux switch-client -t "$selected_name"

if [[ "$current_session" == \#* ]]; then
	tmux kill-session -t "$current_session"
fi
