#!/bin/sh

# Snippet from the official niri-session
# We remove the `import-environment` (and login shell sourcing that became useless), this is needed otherwise SHLVL gets in the systemd env and it breaks stuff

if systemctl --user -q is-active niri.service; then
	echo 'A niri session is already running.'
	exit 1
fi

systemctl --user reset-failed
# still need path to have things like systemctl
systemctl --user import-environment PATH
systemctl --user --wait start niri.service

systemctl --user start --job-mode=replace-irreversibly niri-shutdown.target
systemctl --user unset-environment WAYLAND_DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP NIRI_SOCKET
