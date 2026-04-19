#!/usr/bin/env bash
killall waybar 2>/dev/null
waybar -c "$HOME/.config/waybar/config.jsonc" -s "$HOME/.config/waybar/style.css" &
