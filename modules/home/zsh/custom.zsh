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

