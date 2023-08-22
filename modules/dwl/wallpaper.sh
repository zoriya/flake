#!/usr/bin/env bash

WALLPAPERS=~/wallpapers/

WP=$(find $WALLPAPERS -type f | shuf -n 1)
ln -fs $WP ~/.cache/current-wallpaper

wbg "$WP"
# gsettings set org.gnome.desktop.background picture-uri "$WP"
# gsettings set org.gnome.desktop.background picture-uri-dark "$WP"
