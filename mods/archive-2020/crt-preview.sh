#!/usr/bin/env bash
# Archive (2020) — kitty CRT shader feel comparison
# Approximates what a CRT shader does, using terminal text only. NOT a real
# GLSL shader — just the scanline + contrast parts, which is what most
# people register first. Phosphor bloom, aperture mask, vignette, and barrel
# distortion are pixel-level effects a terminal can't draw — see the bottom
# of the output for what those knobs do.
#
# Run in kitty:
#   bash ~/dotfiles/mods/archive-2020/crt-preview.sh

set -e

# Palette progressions
SMOKE_FULL="232;230;225"   # #e8e6e1   no shader
SMOKE_DIM1="180;176;165"   # subtle contrast drop
SMOKE_DIM2="150;145;130"   # filmic contrast drop
SCAN_SUBTLE="40;38;34"     # barely-visible scanline
SCAN_FILMIC="65;60;52"     # visible scanline
BG="10;10;10"

fg()   { printf "\e[38;2;%sm" "$1"; }
bg()   { printf "\e[48;2;%sm" "$1"; }
rst()  { printf "\e[0m"; }
bold() { printf "\e[1m"; }

SAMPLE=(
  " mello@arch ~ % journalctl --user -u jarvis-arch-agent -n 3 "
  " [22:41:03] connection_open                                 "
  " [22:41:04] auth_approved device=arch01                     "
  " [22:41:05] heartbeat ok rtt=42ms                           "
)
WIDTH=60

label() { fg "120;118;110"; printf "  %s\n" "$1"; rst; }

frame_off() {
    label "OFF — no shader (this is what preview.sh shows today)"
    for line in "${SAMPLE[@]}"; do
        bg "$BG"; fg "$SMOKE_FULL"
        printf "  %s" "$line"
        rst; echo
    done
    echo
}

frame_subtle() {
    label "SUBTLE — faint scanlines, slight contrast drop. Daily-readable."
    for line in "${SAMPLE[@]}"; do
        bg "$BG"; fg "$SMOKE_DIM1"
        printf "  %s" "$line"
        rst; echo
        bg "$BG"; fg "$SCAN_SUBTLE"
        printf "  "
        for ((i=0; i<WIDTH; i++)); do printf "·"; done
        rst; echo
    done
    echo
}

frame_filmic() {
    label "FILMIC — looks like the prop monitors. Small text harder to read."
    for line in "${SAMPLE[@]}"; do
        bg "$BG"; fg "$SMOKE_DIM2"
        printf "  %s" "$line"
        rst; echo
        bg "$BG"; fg "$SCAN_FILMIC"
        printf "  "
        for ((i=0; i<WIDTH; i++)); do printf "─"; done
        rst; echo
    done
    echo
}

echo
bold; fg "$SMOKE_FULL"
printf "  ARCHIVE (2020) — kitty CRT shader feel comparison\n"
rst
fg "120;118;110"
printf "  Same 4-line log, three ways. The real GLSL shader runs as a GPU\n"
printf "  post-process on the kitty framebuffer; this fake only shows the\n"
printf "  scanline + contrast part. Read the notes at the bottom for the\n"
printf "  pixel-level effects a terminal can't draw.\n"
rst
echo

frame_off
frame_subtle
frame_filmic

fg "120;118;110"
printf "  Both modes are OFF on boot. Toggle with a kitty keybind.\n"
printf "\n"
printf "  Shader knobs (what changes between subtle and filmic):\n"
printf "    scanline_intensity   0.05 → 0.30   (shown above)\n"
printf "    contrast_drop        small → larger (shown above)\n"
printf "    phosphor_bloom       0.00 → 1.50   bright pixels bleed sideways\n"
printf "    aperture_mask        0.00 → 0.15   faint RGB stripe over text\n"
printf "    vignette             0.00 → 0.20   corners dim toward black\n"
printf "    barrel_distortion    0.00 → 0.05   slight screen curve\n"
printf "\n"
printf "  The four pixel-level effects (bloom, mask, vignette, curve) are\n"
printf "  what makes a CRT feel like a CRT vs. \"text with stripes\". They\n"
printf "  cost GPU and hurt small-text legibility most.\n"
rst
echo
