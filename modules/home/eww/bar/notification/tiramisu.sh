#!/usr/bin/env bash

tiramisu -j \
    | sed -lu "s/'/\"/g" \
    | sed -lu 's/"urgency": 0x0/"urgency": /' \
    | sed -lu 's/"image-data": \([^},]\+\)/"image-data": "\1"/' \
    | sed -lu "s/&#39/'/" \
    # | tee $HOME/.cache/notif_history \
    | jq --unbuffered -r '(.summary[0:15] + ": " + .body[0:35])'
