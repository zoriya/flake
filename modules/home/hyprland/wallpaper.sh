#!/usr/bin/env bash

WALLPAPERS=~/wallpapers/
export SWWW_TRANSITION_FPS=60
export SWWW_TRANSITION_STEP=2
export SWWW_TRANSITION=grow

WP=$(find $WALLPAPERS -type f | shuf -n 1)
ln -fs $WP ~/.cache/current-wallpaper

[[ "$1" = "init" ]] && swww init && sleep 1
swww img "$WP"
