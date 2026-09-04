#!/usr/bin/env bash
# Archive (2020) — revert. Restores .bak files written by apply.sh and
# removes the generated kitty snippet.
#
# Usage:
#   ./revert.sh                  # revert all phase-1 layers
#   ./revert.sh kitty            # revert just one

set -e

MOD_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES="$(cd "$MOD_DIR/../.." && pwd)"

info()    { printf "\e[38;2;120;118;110m[•]\e[0m %s\n" "$*"; }
success() { printf "\e[38;2;232;230;225m[✓]\e[0m %s\n" "$*"; }
warn()    { printf "\e[38;2;255;176;0m[!]\e[0m %s\n" "$*"; }
section() { printf "\n\e[1m── %s ──────────────────────────────\e[0m\n" "$*"; }

restore_one() {
    local f="$1"
    if [ -f "$f.bak" ]; then
        mv "$f.bak" "$f"
        success "restored $f"
    else
        warn "no backup at $f.bak — leaving current file in place"
    fi
}

revert_kitty() {
    section "kitty"
    local snippet="$DOTFILES/kitty/archive-2020.conf"
    [ -f "$snippet" ] && rm "$snippet" && success "removed $snippet"
    restore_one "$DOTFILES/kitty/kitty.conf"
    if pgrep -x kitty >/dev/null 2>&1; then
        pkill -SIGUSR1 -x kitty 2>/dev/null || true
        info "signalled running kitty instances to reload"
    fi
}

revert_hyprland() {
    section "hyprland"
    restore_one "$DOTFILES/hypr/hyprland.conf"
    if command -v hyprctl >/dev/null 2>&1 && pgrep -x Hyprland >/dev/null 2>&1; then
        hyprctl reload >/dev/null && info "hyprctl reload OK"
    fi
}

revert_hyprlock() {
    section "hyprlock"
    restore_one "$DOTFILES/hypr/hyprlock.conf"
}

revert_fonts() {
    section "fonts"
    # Remove the fontconfig override we wrote
    local fc_file="$HOME/.config/fontconfig/conf.d/99-archive-2020-mono.conf"
    [ -f "$fc_file" ] && rm "$fc_file" && success "removed $fc_file"
    # Restore GTK settings.ini if we had originals; otherwise remove the ones we wrote
    for gtk_ver in 3.0 4.0; do
        local gtk_file="$HOME/.config/gtk-$gtk_ver/settings.ini"
        if [ -f "$gtk_file.bak" ]; then
            restore_one "$gtk_file"
        elif [ -f "$gtk_file" ]; then
            rm "$gtk_file" && success "removed $gtk_file (no prior backup)"
        fi
    done
    # Remove Aldrich from user fonts (leave the system fc-cache; harmless)
    local font_dst="$HOME/.local/share/fonts/Aldrich-Regular.ttf"
    [ -f "$font_dst" ] && rm "$font_dst" && success "removed $font_dst"
    fc-cache -f "$HOME/.local/share/fonts" >/dev/null 2>&1 || true
    info "fc-cache rebuilt"
}

revert_quickshell() {
    section "quickshell"
    restore_one "$HOME/.config/quickshell/modules/stats/Theme.qml"
    restore_one "$HOME/.config/quickshell/shell.qml"
    if pgrep -x qs >/dev/null 2>&1; then
        pkill -x qs 2>/dev/null || true
        (setsid qs >/dev/null 2>&1 &) || true
        info "restarted qs"
    fi
}

revert_rofi() {
    section "rofi"
    local theme="$HOME/.config/rofi/archive-2020.rasi"
    local conf="$HOME/.config/rofi/config.rasi"
    [ -f "$theme" ] && rm "$theme" && success "removed $theme"
    # If we backed up config.rasi, restore it; otherwise strip the @theme line.
    if [ -f "$conf.bak" ]; then
        restore_one "$conf"
    elif [ -f "$conf" ]; then
        sed -i '/^@theme "archive-2020"$/d' "$conf"
        # Also drop the blank line we inserted after the @theme line
        sed -i '1{/^$/d}' "$conf"
        info "stripped @theme line from $conf"
    fi
}

revert_dunst() {
    section "dunst"
    local conf="$HOME/.config/dunst/dunstrc"
    if [ -f "$conf.bak" ]; then
        restore_one "$conf"
    elif [ -f "$conf" ]; then
        rm "$conf" && success "removed $conf (no prior backup — dunst will fall back to /etc/dunst/dunstrc)"
    fi
    if pgrep -x dunst >/dev/null 2>&1; then
        pkill -x dunst 2>/dev/null || true
        (setsid dunst >/dev/null 2>&1 &) || true
        info "restarted dunst"
    fi
}

LAYERS=("$@")
if [ ${#LAYERS[@]} -eq 0 ]; then
    LAYERS=(kitty hyprland hyprlock fonts quickshell rofi dunst)
fi

for layer in "${LAYERS[@]}"; do
    case "$layer" in
        kitty)      revert_kitty ;;
        hyprland)   revert_hyprland ;;
        hyprlock)   revert_hyprlock ;;
        fonts)      revert_fonts ;;
        quickshell) revert_quickshell ;;
        rofi)       revert_rofi ;;
        dunst)      revert_dunst ;;
        *)          warn "unknown layer: $layer (skipping)" ;;
    esac
done

section "done"
