#!/usr/bin/env bash
# Archive (2020) — apply the mod.
# Idempotent: re-running is safe. Per-file .bak created on first touch only.
#
# Usage:
#   ./apply.sh                  # apply all phase-1 layers
#   ./apply.sh kitty            # apply just one layer
#   ./apply.sh kitty hyprland   # apply a subset
#
# Phase-1 layers: kitty, hyprland, hyprlock
# (Waybar, rofi, dunst, gtk, nvim land in later phases — see NOTES.md.)
#
# Revert with: ./revert.sh

set -e

MOD_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES="$(cd "$MOD_DIR/../.." && pwd)"
# shellcheck source=palette.sh
source "$MOD_DIR/palette.sh"

# ── Logging helpers (echo with palette colours) ──────────────────────────────
info()    { printf "\e[38;2;120;118;110m[•]\e[0m %s\n" "$*"; }
success() { printf "\e[38;2;232;230;225m[✓]\e[0m %s\n" "$*"; }
warn()    { printf "\e[38;2;255;176;0m[!]\e[0m %s\n" "$*"; }
section() { printf "\n\e[1m── %s ──────────────────────────────\e[0m\n" "$*"; }

# ── Generic helpers ──────────────────────────────────────────────────────────
backup_once() {
    # Create <file>.bak only if the original exists and no backup already taken.
    # Lets re-runs stay idempotent without overwriting the pristine .bak.
    local f="$1"
    if [ -f "$f" ] && [ ! -f "$f.bak" ]; then
        cp "$f" "$f.bak"
        info "backed up $f → $f.bak"
    fi
}

# ── Layer: kitty ─────────────────────────────────────────────────────────────
apply_kitty() {
    section "kitty"
    local conf="$DOTFILES/kitty/kitty.conf"
    local snippet="$DOTFILES/kitty/archive-2020.conf"

    backup_once "$conf"

    # Generate snippet from palette.sh + extras (font, cursor, chrome, bell).
    # All terminal chrome that the mod cares about lives in this one file so
    # the snippet is the only thing apply.sh writes — main kitty.conf only
    # gets a single `include` line appended.
    {
        "$MOD_DIR/palette.sh" --kitty
        echo
        echo "# ── Font (archive-2020) ─────────────────────────────────────"
        echo "font_family       $ARCHIVE_FONT_BODY"
        echo "bold_font         auto"
        echo "italic_font       auto"
        echo "bold_italic_font  auto"
        echo "font_size         11.0"
        echo "disable_ligatures cursor"
        echo
        echo "# ── Cursor + window chrome (archive-2020) ───────────────────"
        echo "cursor_shape            block"
        echo "cursor_blink_interval   0"
        echo "window_padding_width    8"
        echo "hide_window_decorations yes"
        echo
        echo "# ── Tab bar — inverted highlight on active tab ──────────────"
        echo "tab_bar_style           separator"
        echo "tab_separator           \" │ \""
        echo "active_tab_foreground   $ARCHIVE_INVERT_FG"
        echo "active_tab_background   $ARCHIVE_FG"
        echo "active_tab_font_style   normal"
        echo "inactive_tab_foreground $ARCHIVE_FG_DIM"
        echo "inactive_tab_background $ARCHIVE_BG"
        echo "inactive_tab_font_style normal"
        echo
        echo "# ── Bell (archive-2020) ─────────────────────────────────────"
        echo "enable_audio_bell    no"
        echo "visual_bell_duration 0.08"
        echo "visual_bell_color    $ARCHIVE_WARN"
    } > "$snippet"
    success "wrote $snippet"

    # Append the include line if not already present (idempotent).
    if ! grep -qE '^include[[:space:]]+archive-2020\.conf' "$conf"; then
        printf "\n# Archive (2020) mod — appended by apply.sh\ninclude archive-2020.conf\n" >> "$conf"
        success "added 'include archive-2020.conf' to kitty.conf"
    else
        info "kitty.conf already includes archive-2020.conf"
    fi

    # Live-reload running kitty instances.
    if pgrep -x kitty >/dev/null 2>&1; then
        pkill -SIGUSR1 -x kitty 2>/dev/null || true
        info "signalled running kitty instances to reload"
    fi
}

# ── Layer: hyprland (borders only — see NOTES.md) ───────────────────────────
apply_hyprland() {
    section "hyprland"
    local conf="$DOTFILES/hypr/hyprland.conf"

    backup_once "$conf"

    # Only touch the two border colours. border_size, rounding, opacity, blur
    # are left at the user's existing values. sed substitutions are idempotent
    # — re-running replaces same → same.
    sed -i "s/^\(\s*col\.active_border\s*=\s*\).*/\1rgba(e8e6e1ff)/"   "$conf"
    sed -i "s/^\(\s*col\.inactive_border\s*=\s*\).*/\1rgba(787670ff)/" "$conf"
    success "patched border colours in hyprland.conf"

    if command -v hyprctl >/dev/null 2>&1 && pgrep -x Hyprland >/dev/null 2>&1; then
        hyprctl reload >/dev/null && info "hyprctl reload OK"
    fi
}

# ── Layer: hyprlock (text + input colours; wallpaper/blur untouched) ─────────
apply_hyprlock() {
    section "hyprlock"
    local conf="$DOTFILES/hypr/hyprlock.conf"

    backup_once "$conf"

    # input-field: smoke outline, near-black inner, smoke font
    sed -i "s/^\(\s*outer_color\s*=\s*\).*/\1rgba(232, 230, 225, 0.9)/" "$conf"
    sed -i "s/^\(\s*inner_color\s*=\s*\).*/\1rgba(10, 10, 10, 0.8)/"    "$conf"
    sed -i "s/^\(\s*font_color\s*=\s*\).*/\1rgba(232, 230, 225, 1.0)/"  "$conf"
    sed -i "s/^\(\s*rounding\s*=\s*\).*/\10/"                            "$conf"

    # label colours: first label (clock) bright smoke, second (date) dim smoke.
    # awk because we need positional targeting (which label block we're in).
    awk '
        BEGIN { in_label = 0; n = 0 }
        /^label[[:space:]]*\{/ { in_label = 1; n++ }
        in_label && /^[[:space:]]*\}/ { in_label = 0; print; next }
        in_label && /^[[:space:]]*color[[:space:]]*=/ {
            if (n == 1) { print "    color = rgba(232, 230, 225, 0.95)"; next }
            if (n == 2) { print "    color = rgba(120, 118, 110, 0.85)"; next }
        }
        { print }
    ' "$conf" > "$conf.tmp" && mv "$conf.tmp" "$conf"
    success "patched hyprlock.conf"
}

# ── Layer: fonts (Aldrich install + fontconfig mono pref + GTK 3/4 ui font) ──
apply_fonts() {
    section "fonts"

    # 1) Install Aldrich (OFL, shipped under fonts/ in this mod) into user fonts
    local font_src="$MOD_DIR/fonts/Aldrich-Regular.ttf"
    local font_dst_dir="$HOME/.local/share/fonts"
    local font_dst="$font_dst_dir/Aldrich-Regular.ttf"
    if [ ! -f "$font_src" ]; then
        warn "Aldrich-Regular.ttf missing from $font_src — skipping font install"
    else
        mkdir -p "$font_dst_dir"
        if ! cmp -s "$font_src" "$font_dst" 2>/dev/null; then
            cp "$font_src" "$font_dst"
            success "installed Aldrich → $font_dst"
        else
            info "Aldrich already installed at $font_dst"
        fi
        fc-cache -f "$font_dst_dir" >/dev/null
        info "fc-cache rebuilt"
    fi

    # 2) fontconfig override: prefer JetBrainsMono Nerd for generic monospace.
    # Leaves sans-serif / serif alone — body text in Firefox / PDFs stays readable.
    local fc_dir="$HOME/.config/fontconfig/conf.d"
    local fc_file="$fc_dir/99-archive-2020-mono.conf"
    mkdir -p "$fc_dir"
    cat > "$fc_file" <<'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<!-- Archive (2020) mod — prefer JetBrains Mono Nerd as the generic monospace.
     Sans-serif and serif left at system defaults to keep body text readable. -->
<fontconfig>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>JetBrainsMono Nerd Font</family>
    </prefer>
  </alias>
</fontconfig>
EOF
    success "wrote $fc_file"

    # 3) GTK 3 + 4 settings: ui font + dark theme preference
    for gtk_ver in 3.0 4.0; do
        local gtk_dir="$HOME/.config/gtk-$gtk_ver"
        local gtk_file="$gtk_dir/settings.ini"
        mkdir -p "$gtk_dir"
        backup_once "$gtk_file"
        cat > "$gtk_file" <<EOF
[Settings]
gtk-font-name=$ARCHIVE_FONT_BODY 10
gtk-application-prefer-dark-theme=1
EOF
        success "wrote $gtk_file"
    done
}

# ── Layer: quickshell (Theme.qml + bar/clock in shell.qml) ──────────────────
apply_quickshell() {
    section "quickshell"
    local qs_dir="$HOME/.config/quickshell"
    local theme="$qs_dir/modules/stats/Theme.qml"
    local shell_qml="$qs_dir/shell.qml"

    if [ ! -d "$qs_dir" ]; then
        warn "quickshell config dir not found at $qs_dir — skipping"
        return
    fi

    # Theme.qml is a leaf data file (singleton with only property declarations),
    # so a full rewrite is the cleanest path. backup_once preserves the original.
    backup_once "$theme"
    cat > "$theme" <<EOF
pragma Singleton
import QtQuick

// Archive (2020) mod — generated by apply.sh.
// Two-tone palette: smoke white for chrome, amber for warning/alert only.
QtObject {
    // surface
    property color bg:           "$ARCHIVE_BG"
    property color bgElevated:   "$ARCHIVE_BG_ALT"
    property color bgHover:      "#1f1f1f"
    property color border:       "$ARCHIVE_FG_DIM"

    // text
    property color text:         "$ARCHIVE_FG"
    property color textMuted:    "$ARCHIVE_FG_DIM"
    property color textStrong:   "$ARCHIVE_FG"

    // accents — all smoke variants; rule is "no chroma except amber for warning"
    property color accentCpu:      "$ARCHIVE_FG"
    property color accentRam:      "#c8c5be"
    property color accentGpu:      "#9c9890"
    property color accentBattery:  "#b6b3aa"
    property color accentNet:      "$ARCHIVE_FG"

    // semantic — warning/danger are amber per the two-tone rule
    property color ok:        "$ARCHIVE_FG"
    property color warning:   "$ARCHIVE_WARN"
    property color danger:    "$ARCHIVE_WARN"
    property color info:      "$ARCHIVE_FG_DIM"

    // net directions
    property color netUp:     "$ARCHIVE_FG"
    property color netDown:   "$ARCHIVE_FG_DIM"

    // sizing — square corners per design rule
    property real radius:      0
    property real radiusSmall: 0
    property real cardOpacity: 0.95
}
EOF
    success "wrote $theme"

    # shell.qml: bar bg + clock fg + clock font.family (the display font moment)
    backup_once "$shell_qml"
    sed -i 's|"#801e1e2e"|"#cc0a0a0a"|'  "$shell_qml"  # bar bg
    sed -i 's|"#cdd6f4"|"'"$ARCHIVE_FG"'"|' "$shell_qml"  # clock fg
    if ! grep -q "font.family: \"$ARCHIVE_FONT_DISPLAY\"" "$shell_qml"; then
        # Insert font.family on the line after font.pixelSize: 13 (the clock).
        sed -i '/font\.pixelSize: 13/a\                font.family: "'"$ARCHIVE_FONT_DISPLAY"'"' "$shell_qml"
        success "added font.family: \"$ARCHIVE_FONT_DISPLAY\" to clock"
    else
        info "clock font.family already set"
    fi
    success "patched $shell_qml"

    # Restart quickshell to pick up Theme.qml + shell.qml changes
    if pgrep -x qs >/dev/null 2>&1; then
        pkill -x qs 2>/dev/null || true
        # Detach so this script doesn't hold qs's lifetime
        (setsid qs >/dev/null 2>&1 &) || true
        info "restarted qs"
    else
        info "qs not running — start it manually or relogin"
    fi
}

# ── Layer: rofi (theme file + @theme include in user config) ────────────────
apply_rofi() {
    section "rofi"
    local rofi_dir="$HOME/.config/rofi"
    local theme="$rofi_dir/archive-2020.rasi"
    local conf="$rofi_dir/config.rasi"

    mkdir -p "$rofi_dir"

    # Write the theme file. Generated each apply so palette edits propagate.
    # Aggressive about backgrounds — rofi's built-in defaults leak through
    # any container we don't explicitly override.
    cat > "$theme" <<EOF
/* Archive (2020) — generated by apply.sh
   Aggressive override: every visible container sets bg/fg explicitly. */

configuration {
    show-icons:          false;
    display-drun:        "";
    display-run:         "";
    display-window:      "";
    display-ssh:         "";
    drun-display-format: "{name}";
    me-select-entry:     "";
    me-accept-entry:     "MousePrimary";
}

* {
    bg:           $ARCHIVE_BG;
    bg-alt:       $ARCHIVE_BG_ALT;
    fg:           $ARCHIVE_FG;
    fg-dim:       $ARCHIVE_FG_DIM;
    warn:         $ARCHIVE_WARN;
    inverted-fg:  $ARCHIVE_INVERT_FG;

    font-body:    "$ARCHIVE_FONT_BODY 11";
    font-display: "$ARCHIVE_FONT_DISPLAY 14";

    background-color: transparent;
    text-color:       @fg;
}

window {
    background-color: @bg;
    border:           1px solid;
    border-color:     @fg-dim;
    border-radius:    0;
    padding:          12px;
    width:            520px;
    location:         center;
    anchor:           center;
    font:             @font-body;
}

mainbox {
    background-color: @bg;
    children:         [ inputbar, listview ];
    spacing:          10px;
}

inputbar {
    background-color: @bg;
    children:         [ prompt, entry ];
    spacing:          10px;
    padding:          4px 0 8px 0;
    border:           0 0 1px 0;
    border-color:     @fg-dim;
}

prompt {
    background-color: @bg;
    text-color:       @fg;
    font:             @font-display;
    str:              "❯";
}

entry {
    background-color:  @bg;
    text-color:        @fg;
    placeholder-color: @fg-dim;
    placeholder:       "search";
    font:              @font-body;
    cursor:            text;
}

listview {
    background-color: @bg;
    lines:            8;
    spacing:          1px;
    scrollbar:        false;
    fixed-height:     true;
}

element {
    background-color: @bg;
    text-color:       @fg;
    padding:          5px 10px;
    cursor:           pointer;
}

element-text {
    background-color: inherit;
    text-color:       inherit;
    vertical-align:   0.5;
    font:             @font-body;
}

/* Inverted highlight — Archive's signature "this is active" gesture */
element selected {
    background-color: @fg;
    text-color:       @inverted-fg;
}

element selected element-text {
    background-color: inherit;
    text-color:       inherit;
}
EOF
    success "wrote $theme"

    # Add @theme import to the top of config.rasi, idempotently. The user's
    # config.rasi has real content below (timeout, filebrowser) — preserve it.
    backup_once "$conf"
    if ! grep -q '@theme "archive-2020"' "$conf" 2>/dev/null; then
        if [ -f "$conf" ]; then
            sed -i '1i @theme "archive-2020"\n' "$conf"
        else
            printf '@theme "archive-2020"\n\nconfiguration { }\n' > "$conf"
        fi
        success "added @theme \"archive-2020\" to $conf"
    else
        info "config.rasi already imports archive-2020 theme"
    fi
}

# ── Layer: dunst (no existing user config — first write creates it) ─────────
apply_dunst() {
    section "dunst"
    local dunst_dir="$HOME/.config/dunst"
    local conf="$dunst_dir/dunstrc"
    mkdir -p "$dunst_dir"
    backup_once "$conf"

    cat > "$conf" <<EOF
# Archive (2020) — generated by apply.sh
# Two-tone: smoke white on near-black for normal, amber for critical.

[global]
    monitor = 0
    follow = mouse
    width = 320
    height = 100
    origin = top-right
    offset = 12x12
    notification_limit = 5
    progress_bar = true
    progress_bar_height = 6
    progress_bar_frame_width = 0
    progress_bar_min_width = 200
    progress_bar_max_width = 300
    indicate_hidden = yes
    transparency = 0
    separator_height = 1
    padding = 10
    horizontal_padding = 12
    text_icon_padding = 8
    frame_width = 1
    frame_color = "$ARCHIVE_FG_DIM"
    gap_size = 6
    separator_color = frame
    sort = yes
    font = $ARCHIVE_FONT_BODY 10
    line_height = 0
    markup = full
    format = "<b>%s</b>\n%b"
    alignment = left
    vertical_alignment = center
    show_age_threshold = 60
    ellipsize = end
    ignore_newline = no
    stack_duplicates = true
    hide_duplicate_count = false
    show_indicators = yes
    icon_position = off
    sticky_history = yes
    history_length = 20
    corner_radius = 0
    ignore_dbusclose = false

[urgency_low]
    background = "$ARCHIVE_BG"
    foreground = "$ARCHIVE_FG_DIM"
    timeout = 4

[urgency_normal]
    background = "$ARCHIVE_BG"
    foreground = "$ARCHIVE_FG"
    timeout = 6

# Critical: amber type + amber frame. The "alert" rule in action.
[urgency_critical]
    background = "$ARCHIVE_BG"
    foreground = "$ARCHIVE_WARN"
    frame_color = "$ARCHIVE_WARN"
    timeout = 0
EOF
    success "wrote $conf"

    # Reload dunst (it watches for SIGUSR2? No — restart instead)
    if pgrep -x dunst >/dev/null 2>&1; then
        pkill -x dunst 2>/dev/null || true
        (setsid dunst >/dev/null 2>&1 &) || true
        info "restarted dunst"
    fi
}

# ── Dispatch ────────────────────────────────────────────────────────────────
LAYERS=("$@")
if [ ${#LAYERS[@]} -eq 0 ]; then
    LAYERS=(kitty hyprland hyprlock fonts quickshell rofi dunst)
fi

for layer in "${LAYERS[@]}"; do
    case "$layer" in
        kitty)      apply_kitty ;;
        hyprland)   apply_hyprland ;;
        hyprlock)   apply_hyprlock ;;
        fonts)      apply_fonts ;;
        quickshell) apply_quickshell ;;
        rofi)       apply_rofi ;;
        dunst)      apply_dunst ;;
        *)          warn "unknown layer: $layer (skipping)" ;;
    esac
done

section "done"
printf "  Revert with: %s/revert.sh\n" "$MOD_DIR"
printf "  All current layers applied (kitty + hyprland + hyprlock + fonts + quickshell + rofi + dunst).\n"
