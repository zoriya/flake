#!/usr/bin/env bash

${1:-tiramisu} -s -o '{"title": "#source: #summary", "message": "#body", "topic": "zoriya"}' | xargs -L1 -d\\n curl ntfy.sh -d
