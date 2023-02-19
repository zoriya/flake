#!/usr/bin/env bash

eww windows | grep '*panel' > /dev/null
[[ $? -eq 0 ]] \
    && (eww close panel-closer && eww close panel) \
    || (eww open panel-closer && eww open panel)
