#!/usr/bin/env bash

WALLPAPERS=~/wallpapers/
export SWWW_TRANSITION_FPS=90
export SWWW_TRANSITION_STEP=90
export SWWW_TRANSITION_DURATION=2
export SWWW_TRANSITION=grow

WP=$(find $WALLPAPERS -type f | shuf -n 1)
ln -fs $WP ~/.cache/current-wallpaper

gsettings set org.gnome.desktop.background picture-uri "$WP"
gsettings set org.gnome.desktop.background picture-uri-dark "$WP"
