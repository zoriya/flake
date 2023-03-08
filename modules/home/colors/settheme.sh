#!/usr/bin/env bash

set -e

GENERATION=$(home-manager generations | cut -d \> -f 2 | cut -c2- | sed 's@$@/specialization/@' | xargs -d \\n -I{} find "{}" -type d 2> /dev/null | head -n1)
CURRENT_THEME=$(cat ~/.local/state/theme)
THEME=${1:-$([ "$CURRENT_THEME" == "light" ] && echo "dark" || echo "light")}

echo "Current generation is $GENERATION, current theme is $CURRENT_THEME."
echo "Switching to theme $THEME"

"$GENERATION/$THEME/activate"
