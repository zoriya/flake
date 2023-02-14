#!/usr/bin/env bash

WALLPAPERS=~/wallpapers/
export SWWW_TRANSITION_FPS=60
export SWWW_TRANSITION_STEP=2
export SWWW_TRANSITION=grow

swww img "$(find $WALLPAPERS -type f | shuf -n 1)"
