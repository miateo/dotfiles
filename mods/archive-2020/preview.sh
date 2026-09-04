#!/usr/bin/env bash
# Archive (2020) — palette preview
# ANSI truecolor mockup of the locked palette, a waybar row, a kitty prompt,
# dunst notifications, and hyprland active/inactive borders. Run in kitty:
#   bash ~/dotfiles/mods/archive-2020/preview.sh
# No system changes — just prints to stdout.

set -e

# Locked palette (mirror of palette.sh once it lands)
SMOKE_FG="232;230;225"   # #e8e6e1  primary fg
DIM="120;118;110"        # #787670  muted smoke (inactive)
AMBER="255;176;0"        # #ffb000  WARNING only
BG="10;10;10"            # #0a0a0a  surface
SURFACE_ALT="20;20;20"   # #141414  raised surface

fg()   { printf "\e[38;2;%sm" "$1"; }
bg()   { printf "\e[48;2;%sm" "$1"; }
rst()  { printf "\e[0m"; }
bold() { printf "\e[1m"; }

echo
bold; fg "$SMOKE_FG"; printf "  ARCHIVE (2020) — palette preview\n"; rst
echo

# ── Swatches ─────────────────────────────────────────────────────────────────
swatch() {
    local color="$1" name="$2" hex="$3" note="$4"
    bg "$color"; fg "10;10;10"; printf "         "; rst
    fg "$SMOKE_FG"; printf "  %-14s" "$name"
    fg "$DIM"; printf "%-10s %s\n" "$hex" "$note"; rst
}

swatch "$SMOKE_FG"    "smoke white"  "#e8e6e1" "primary fg"
swatch "$DIM"         "dim smoke"    "#787670" "inactive text"
swatch "$AMBER"       "amber"        "#ffb000" "WARNING only"
swatch "$BG"          "surface"      "#0a0a0a" "bg"
swatch "$SURFACE_ALT" "surface +1"   "#141414" "raised bg"

# ── Mock waybar row ──────────────────────────────────────────────────────────
echo
fg "$DIM"; printf "  waybar mock (focused workspace is smoke white; amber only on BAT alert):\n"; rst
bg "$BG"; fg "$SMOKE_FG"
printf "  "
printf "  1 "                                             # focused = smoke
fg "$DIM"; printf "  2   3   4 "; fg "$SMOKE_FG"          # inactive = dim
printf "      "
printf "  12%%   4.2G   ↓ 1.2M ↑ 80K  "
fg "$AMBER"; printf "   ⚠ BAT 8%%  "; fg "$SMOKE_FG"      # warning = amber
printf "    22:41  "
rst
echo

# ── Mock kitty session ───────────────────────────────────────────────────────
echo
fg "$DIM"; printf "  kitty mock (amber appears only on the failed state):\n"; rst
bg "$BG"; fg "$SMOKE_FG"
echo "  ┌─────────────────────────────────────────────────────────────┐"
echo "  │ mello@arch ~ % systemctl --user status jarvis-arch-agent    │"
echo "  │ ● jarvis-arch-agent.service                                 │"
echo "  │    Loaded: loaded (enabled; preset: enabled)                │"
printf "  │    Active: "; fg "$AMBER"; printf "failed"; fg "$SMOKE_FG"; printf " (Result: exit-code)             │\n"
echo "  │   Process: 1247 ExecStart=... (code=exited, status=1)       │"
echo "  │ mello@arch ~ %                                              │"
echo "  └─────────────────────────────────────────────────────────────┘"
rst
echo

# ── Mock dunst ───────────────────────────────────────────────────────────────
fg "$DIM"; printf "  dunst mock (normal then urgent):\n"; rst

bg "$SURFACE_ALT"; fg "$SMOKE_FG"
echo "  ┌──────────────────────────────────────┐"
echo "  │ Spotify                              │"
echo "  │ Strangelove — Depeche Mode           │"
echo "  └──────────────────────────────────────┘"
rst

bg "$SURFACE_ALT"; fg "$AMBER"
echo "  ┌──────────────────────────────────────┐"
echo "  │ ⚠ system                             │"
echo "  │ Battery at 8% — connect charger      │"
echo "  └──────────────────────────────────────┘"
rst

# ── Mock hyprland border (active vs inactive) ────────────────────────────────
echo
fg "$DIM"; printf "  hyprland border mock (active above, inactive below):\n"; rst
bg "$BG"; fg "$SMOKE_FG"
echo "  ┌──────── active ──────────────┐"
echo "  │                              │"
echo "  └──────────────────────────────┘"
rst
bg "$BG"; fg "$DIM"
echo "  ┌──────── inactive ────────────┐"
echo "  │                              │"
echo "  └──────────────────────────────┘"
rst

echo
fg "$DIM"; printf "  done. eyeball, then commit to palette.sh.\n"; rst
echo
