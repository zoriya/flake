#!/usr/bin/env bash
set -e

name=$(guessit "$1" -P "title" | tr -d "[:punct:]")

ls /mnt/kyoo/shows/ | tr -d "[:punct:]" | grep -qix "$name"

echo "Downloading $1"
exit 80
