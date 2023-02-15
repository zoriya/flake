#!/usr/bin/env bash

tiramisu -j \
    | sed -u "s/'/\"/g" \
    | sed -u 's/"urgency": 0x0/"urgency": /' \
    | sed -u 's/"image-data": \([^},]\+\)/"image-data": "\1"/' \
    | sed -u "s/&#39/'/" \
    | tee $HOME/.cache/notif_history \
    | jq --unbuffered -r '(.summary[0:15] + ": " + .body[0:35])'
