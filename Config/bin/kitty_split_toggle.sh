#!/usr/bin/env bash
# Alterna la dirección del split de kitty: hsplit → vsplit → hsplit → ...
# Requiere allow_remote_control yes en kitty.conf.
STATE="${XDG_RUNTIME_DIR:-/tmp}/kitty_split_state"

if [ "$(cat "$STATE" 2>/dev/null)" = "v" ]; then
    kitty @ launch --location=vsplit --cwd=current
    echo "h" > "$STATE"
else
    kitty @ launch --location=hsplit --cwd=current
    echo "v" > "$STATE"
fi
