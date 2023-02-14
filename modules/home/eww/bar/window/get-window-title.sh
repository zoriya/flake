#!/usr/bin/env bash

MAXCHAR=40

hyprctl activewindow -j | jq --raw-output .title | cut -c -$MAXCHAR
socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | stdbuf -o0 grep '^activewindow>>' | stdbuf -o0 awk -F '>>|,' '{print $3}' | stdbuf -o0 cut -c -$MAXCHAR

