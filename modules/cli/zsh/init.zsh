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

# * empty is not an error
setopt rm_star_silent
# allow comments in interactive sessions
setopt interactivecomments

# ctrl-left/right
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

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

	ENV=$(cat $DOTENV | sed '/^#/d' | tr '\n' ' ')

	if [[ -z $* ]]; then
		export ${=ENV}
	else
		(export ${=ENV}; $*)
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
