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

# Make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
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

# ^Z when a job is suspended runs it in the foreground.
foreground() {
	fg
}
zle -N foreground
bindkey ^Z foreground

eval "$(nix-your-shell zsh)"

# * empty is not an error
setopt rm_star_silent
# allow comments in interactive sessions
setopt interactivecomments

(whence -w run-help | grep -q alias) && unalias run-help
autoload run-help

# Allow customization per client.
[[ -f ~/.config/zsh/custom.zsh ]] && source ~/.config/zsh/custom.zsh



push() {
	if [[ -z "$1" ]]; then
		git push
		return
	fi
	git add -A && git commit -m "$*" && git push
}

git-branch-clear() {
	git fetch --prune origin
	git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D
}

nixify() {
	if [ ! -e ./.envrc ]; then
		echo "use nix" > .envrc
	fi
	if [[ ! -e shell.nix ]]; then
		cat > shell.nix <<'EOF'
{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
	packages = with pkgs; [

	];
}
EOF
	fi
	direnv allow
}

flakify() {
	if [ ! -e flake.nix ]; then
		nix flake new -t github:nix-community/nix-direnv .
	elif [ ! -e .envrc ]; then
		echo "use flake" > .envrc
	fi
	direnv allow
}

dotenv() {
	DOTENV=".env"
	if [[ $1 == "-f" ]]; then
		DOTENV=$2
		shift
		shift
	fi

	if [[ -z $* ]]; then
		set -a && source $DOTENV && set +a
	else
		(set -a && source $DOTENV && set +a && $*)
	fi
}

robot_install() {
	robot=$(\where -p robot)
	if [[ $? -eq 1 ]]; then 
		pyt=$(\where -p python3)
		if [[ $? -eq 1 ]]; then
			nix-shell -p python3
		fi

		python3 -m venv /tmp/robot
		source /tmp/robot/bin/activate
		pip3 install robotframework RESTinstance
	fi
}

touchp() {
	mkdir -p "$(dirname "$1")" && touch "$1"
}

proxy() {
	echo "Proxying port $1 to http://proxy.sdg.moe"
	ssh -NR "5000:localhost:$1" ssh.sdg.moe
}

# disable space between right prompt and end of line
ZLE_RPROMPT_INDENT=0
