#!/usr/bin/env bash

spaces (){
    hyprctl workspaces -j | jq -c 'map(.id | select(. > 0)) | sort'
}

spaces
socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
	spaces
done
