#!/usr/bin/env bash
killall waybar 2>/dev/null
sleep 0.2
LOG="$HOME/.cache/waybar.log"
mkdir -p "$(dirname "$LOG")"
setsid -f waybar     -c "$HOME/.config/waybar/config.jsonc"     -s "$HOME/.config/waybar/style.css"     </dev/null >/dev/null 2>"$LOG"
