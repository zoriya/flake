# Create a new tmux session (with a random name) and attach.
if [[ -z "$TMUX" ]]; then
	exec tmux new-session -s "$(hexdump -n 4 -v -e '/1 "%02X"' /dev/urandom)"
fi

# This speeds up pasting w/ autosuggest
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
	OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
	zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}

pastefinish() {
	zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

function zvm_before_init() {
	# Restore nice history search that zsh-vi-mode disable.
	zvm_bindkey viins '^[[A' history-search-backward
	zvm_bindkey viins '^[[B' history-search-forward
	zvm_bindkey vicmd '^[[A' history-search-backward
	zvm_bindkey vicmd '^[[B' history-search-forward
}

function zvm_after_init() {
	# Restore plugin bindings that zsh-vi-mode overrides.
	bindkey '^r' _atuin_search_widget
	bindkey '^[d' kill-word
	ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT

	# ^Z when a job is suspended runs it in the foreground.
	foreground() {
		fg
	}
	zle -N foreground
	bindkey ^Z foreground

}

eval "$(nix-your-shell zsh)"

setopt rm_star_silent

# case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# use LS_COLORS for autocompletion
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# ctrl-left/right
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
