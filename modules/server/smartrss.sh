#!/usr/bin/env bash
set -e

name=$(guessit "$1" -P "title")

# curl -s 'http://localhost:3000/api/torrents' -b $(cat /var/lib/flood/flood.cookiefile) |
# 	jq '.torrents.[].directory' -r |
#	sed s@/mnt/kyoo/shows/@@ |
ls /mnt/kyoo/shows/ | grep -qix "$name"

echo "Downloading $1"
exit 80
