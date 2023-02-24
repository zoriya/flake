push()
{
	if [[ -z "$1" ]]; then
		git push
		return
	fi
	git add -A && git commit -m "$*" && git push
}

nixify()
{
	if [ ! -e flake.nix ]; then
		nix flake new -t github:nix-community/nix-direnv .
	elif [ ! -e .envrc ]; then
		echo "use flake" > .envrc
	fi
	direnv allow
}
