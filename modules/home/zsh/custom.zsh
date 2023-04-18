push()
{
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
	if [[ ! -e shell.nix ]] && [[ ! -e default.nix ]]; then
		cat > default.nix <<'EOF'
{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
	packages = with pkgs; [

	];
}
EOF
	fi
	direnv allow
}

flakify()
{
	if [ ! -e flake.nix ]; then
		nix flake new -t github:nix-community/nix-direnv .
	elif [ ! -e .envrc ]; then
		echo "use flake" > .envrc
	fi
	direnv allow
}

(whence -w run-help | grep -q alias) && unalias run-help
autoload run-help

# Allow customization per client.
[[ -f ~/.config/zsh/custom.zsh ]] && source ~/.config/zsh/custom.zsh

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
