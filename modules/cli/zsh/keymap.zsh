# Make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx; }
	function zle_application_mode_stop { echoti rmkx; }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# setup keys
typeset -g -A key
key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"
key[Control-Left]="${terminfo[kLFT5]}"
key[Control-Right]="${terminfo[kRIT5]}"

# start with base emacs commands
bindkey -e

bindkey "${key[Home]}"       beginning-of-line
bindkey "${key[End]}"        end-of-line
bindkey "${key[Insert]}"     overwrite-mode
bindkey "${key[Backspace]}"  backward-delete-char
bindkey "${key[Delete]}"     delete-char
bindkey "${key[Left]}"       backward-char
bindkey "${key[Right]}"      forward-char
bindkey "${key[PageUp]}"     beginning-of-buffer-or-history
bindkey "${key[PageDown]}"   end-of-buffer-or-history
bindkey "${key[Shift-Tab]}"  reverse-menu-complete

bindkey "${key[Control-Left]}"  backward-word
bindkey "${key[Control-Right]}" forward-word

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "${key[Up]}"   up-line-or-beginning-search
bindkey "${key[Down]}" down-line-or-beginning-search

