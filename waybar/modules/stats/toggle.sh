#!/usr/bin/env bash
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}
LOG=/tmp/eww-toggle.log
echo "[$(date +%T)] clicked. active=$(eww active-windows 2>&1)" >> "$LOG"
if eww active-windows 2>/dev/null | grep -q '^stats'; then
    eww close stats >> "$LOG" 2>&1
else
    eww open stats >> "$LOG" 2>&1
fi
