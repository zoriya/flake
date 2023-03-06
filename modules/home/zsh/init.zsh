if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
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
    bindkey '\ej' jq-complete
    bindkey '^[d' kill-word
	ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
}

export YSU_MESSAGE_FORMAT="Alias: %alias";
export YSU_IGNORED_ALIASES=("g" "-" "~" "/" ".." "..." "...." "....." "md" "rd")
export DIRENV_LOG_FORMAT=
eval "$(atuin init zsh)"
eval "$(nix-your-shell zsh)"
