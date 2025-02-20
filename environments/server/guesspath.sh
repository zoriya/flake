#!/usr/bin/env bash

set -e

OUT=/mnt/kyoo/shows

if [[ -n "$TR_TORRENT_LABELS" ]]; then
	echo "Ignoring $TR_TORRENT_NAME since it has labels $TR_TORRENT_LABELS"
	exit
fi
if [[ "$TR_TORRENT_DIR" != "/mnt/kyoo/download" ]]; then
	echo "Ignoring $TR_TORRENT_NAME since it already has a dir set: $TR_TORRENT_DIR"
	exit
fi
echo "Running with $TR_TORRENT_NAME $TR_TORRENT_ID"

name=$TR_TORRENT_NAME
dir=$(guessit "$name" -P "title")
echo "Guessed '$dir' for torrent '$name'"

transmission-remote -t "$TR_TORRENT_ID" --move "$OUT/$dir"
