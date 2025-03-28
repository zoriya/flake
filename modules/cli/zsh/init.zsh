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
# https://github.com/zsh-users/zsh-autosuggestions/issues/351
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)

# ^Z when a job is suspended runs it in the foreground.
foreground() {
	fg
}
zle -N foreground
bindkey ^Z foreground

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
	ssh -NR "5000:localhost:$1" zoriya@ssh.sdg.moe
}
