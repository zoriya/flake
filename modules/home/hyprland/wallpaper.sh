#!/usr/bin/env bash

WALLPAPERS=~/wallpapers/
export SWWW_TRANSITION_FPS=90
export SWWW_TRANSITION_STEP=90
export SWWW_TRANSITION_DURATION=2
export SWWW_TRANSITION=grow

WP=$(find $WALLPAPERS -type f | shuf -n 1)
ln -fs $WP ~/.cache/current-wallpaper

[[ "$1" = "init" ]] && swww init && sleep 1
swww img "$WP"
