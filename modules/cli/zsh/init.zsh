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
bindkey '^Z' foreground

(whence -w run-help | grep -q alias) && unalias run-help
autoload run-help

autoload edit-command-line
zle -N edit-command-line
bindkey '^Xe' edit-command-line

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

touchp() {
	mkdir -p "$(dirname "$1")" && touch "$1"
}

s() {
	git status 2>/dev/null
	if [[ $? -ne 0 ]]; then
		gfold
	fi
}

# keep yq's output in yaml & colorizes it
yq() {
	# if `-r` is in the arguments, do not add the -Y flag because it breaks yq.
	if ! (( $argv[(I)-r] )); then
		argv+=(-Y)
	fi
	command yq "${argv[@]}" | bat -ppl yaml
}

kgy() {
	kubectl get -o yaml "$@" | yq 'if .kind == "Secret" then .stringData = (.data | with_entries(.value |= @base64d)) else . end'
}
_kgy() {
	words="kubectl get -o yaml ${words[@]:1}"
	_kubectl
}
compdef _kgy kgy

alias copyfile="osc copy"
copypath() {
	local file="${1:-.}"
	[[ $file = /* ]] || file="$PWD/$file"
	print -n "${file:a}" | osc copy || return 1
}
