#!/usr/bin/env bash

layout() {
    WORKSPACE=$(hyprctl monitors -j | jq '.[0].activeWorkspace.id')
    IS_FULLSCREEN=$(hyprctl workspaces -j | jq ".[] | select(.id == $WORKSPACE).hasfullscreen")
    [ $IS_FULLSCREEN = "true" ] \
        && echo "[$(hyprctl workspaces -j | jq ".[] | select(.id == $WORKSPACE).windows")]" \
        || echo "[]="
}


layout
socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
    layout
done
