#!/usr/bin/env bash
# =============================================================================
# install.sh — Arch Linux bootstrap + dotfiles setup
# Usage (fresh machine):
#   git clone https://github.com/miateo/dotfiles ~/dotfiles
#   cd ~/dotfiles && bash install.sh
# =============================================================================

set -e

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[•]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[!]${RESET} $*"; }
error()   { echo -e "${RED}[✗]${RESET} $*"; exit 1; }
section() { echo -e "\n${BOLD}━━━ $* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; }

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# =============================================================================
# 1. SYSTEM UPDATE
# =============================================================================
section "System update"
sudo pacman -Syu --noconfirm
success "System up to date"

# =============================================================================
# 2. CORE DEPENDENCIES (needed before everything else)
# =============================================================================
section "Core dependencies"
CORE=(
    base-devel     # AUR builds
    git
    curl
    wget
    unzip
    zip
    p7zip
    xdg-user-dirs
    xdg-utils
)
sudo pacman -S --needed --noconfirm "${CORE[@]}"
success "Core dependencies installed"

# =============================================================================
# 3. AUR HELPER — yay
# =============================================================================
section "AUR helper (yay)"
if ! command -v yay &>/dev/null; then
    info "Installing yay..."
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    (cd "$tmpdir/yay" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
    success "yay installed"
else
    success "yay already present"
fi

# =============================================================================
# 4. DISPLAY SERVER / WAYLAND
# =============================================================================
section "Wayland / display"
WAYLAND=(
    wayland
    wayland-protocols
    xorg-xwayland         # X11 compat layer
    qt5-wayland
    qt6-wayland
    glfw-wayland
)
sudo pacman -S --needed --noconfirm "${WAYLAND[@]}"
success "Wayland stack installed"

# =============================================================================
# 5. HYPRLAND + ECOSYSTEM
# =============================================================================
section "Hyprland"
HYPR=(
    hyprland
    hyprpaper             # wallpaper daemon
    hyprlock              # lockscreen
    hypridle              # idle daemon
    xdg-desktop-portal-hyprland
    polkit-kde-agent      # polkit agent for GUI auth prompts
    qt5ct                 # Qt5 theming under Wayland
    qt6ct
    nwg-look              # GTK settings for Wayland
)
sudo pacman -S --needed --noconfirm "${HYPR[@]}"

# hyprshot for screenshots (AUR)
yay -S --needed --noconfirm hyprshot 2>/dev/null || warn "hyprshot not found in AUR, skipping"
success "Hyprland installed"

# =============================================================================
# 6. WAYBAR
# =============================================================================
section "Waybar"
WAYBAR=(
    waybar
    otf-font-awesome      # icons used by most waybar configs
    ttf-nerd-fonts-symbols-mono
)
sudo pacman -S --needed --noconfirm "${WAYBAR[@]}"
success "Waybar installed"

# =============================================================================
# 7. TERMINAL — Kitty
# =============================================================================
section "Kitty terminal"
sudo pacman -S --needed --noconfirm kitty
success "Kitty installed"

# =============================================================================
# 8. SHELL — zsh + extras
# =============================================================================
section "Shell (zsh)"
ZSH_PKGS=(
    zsh
    zsh-completions
    zsh-autosuggestions
    zsh-syntax-highlighting
    starship              # prompt (common in hyprland rices)
)
sudo pacman -S --needed --noconfirm "${ZSH_PKGS[@]}"

if [ "$SHELL" != "$(which zsh)" ]; then
    info "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
    success "Default shell set to zsh (takes effect on next login)"
else
    success "zsh already default shell"
fi

# =============================================================================
# 9. NEOVIM
# =============================================================================
section "Neovim"
NVIM_PKGS=(
    neovim
    python-pynvim         # Python provider
    nodejs                # LSP servers often need Node
    npm
    ripgrep               # telescope.nvim live grep
    fd                    # telescope file finder
    tree-sitter           # treesitter CLI
    lazygit               # used by lazygit.nvim
    xclip                 # clipboard bridge
)
sudo pacman -S --needed --noconfirm "${NVIM_PKGS[@]}"
success "Neovim + deps installed"

# =============================================================================
# 10. LAZYGIT (standalone, also a dep above — belt + suspenders)
# =============================================================================
section "Lazygit"
sudo pacman -S --needed --noconfirm lazygit
success "Lazygit installed"

# =============================================================================
# 11. FASTFETCH
# =============================================================================
section "Fastfetch"
sudo pacman -S --needed --noconfirm fastfetch
success "Fastfetch installed"

# =============================================================================
# 12. ZATHURA (PDF viewer)
# =============================================================================
section "Zathura"
ZATHURA=(
    zathura
    zathura-pdf-mupdf     # PDF backend
    zathura-djvu          # DjVu support (optional, harmless)
)
sudo pacman -S --needed --noconfirm "${ZATHURA[@]}"
success "Zathura installed"

# =============================================================================
# 13. SPOTIFY + SPICETIFY
# =============================================================================
section "Spotify + Spicetify"

# Spotify (AUR)
if ! command -v spotify &>/dev/null; then
    info "Installing Spotify from AUR..."
    yay -S --needed --noconfirm spotify
    success "Spotify installed"
else
    success "Spotify already present"
fi

# Spicetify
if ! command -v spicetify &>/dev/null; then
    info "Installing Spicetify..."
    # Official install method
    curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh
    success "Spicetify installed"
else
    success "Spicetify already present"
fi

# =============================================================================
# 14. FONTS (common choices for Hyprland rices)
# =============================================================================
section "Fonts"
FONTS=(
    ttf-jetbrains-mono-nerd
    ttf-nerd-fonts-symbols
    noto-fonts
    noto-fonts-emoji
    ttf-liberation
)
sudo pacman -S --needed --noconfirm "${FONTS[@]}"
success "Fonts installed"

# =============================================================================
# 15. AUDIO (pipewire stack — standard for modern Arch/Wayland)
# =============================================================================
section "Audio (Pipewire)"
AUDIO=(
    pipewire
    pipewire-alsa
    pipewire-pulse
    pipewire-jack
    wireplumber
    pavucontrol           # GUI volume control
)
sudo pacman -S --needed --noconfirm "${AUDIO[@]}"
success "Audio stack installed"

# =============================================================================
# 16. MISC WAYLAND UTILITIES (commonly needed with Hyprland configs)
# =============================================================================
section "Wayland utilities"
UTILS=(
    dunst                 # notification daemon
    rofi-wayland          # launcher (rofi fork for Wayland)
    swww                  # wallpaper daemon alternative
    cliphist              # clipboard history
    wl-clipboard          # wl-copy / wl-paste
    brightnessctl         # backlight control
    networkmanager
    network-manager-applet
    bluez
    bluez-utils
    blueman               # Bluetooth GUI
    thunar                # file manager
    gvfs                  # virtual filesystem for Thunar
    file-roller           # archive manager
    imv                   # image viewer
    mpv                   # video player
)
sudo pacman -S --needed --noconfirm "${UTILS[@]}"

# Enable services
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
success "Utilities installed and services enabled"

# =============================================================================
# 17. LINK DOTFILES
# =============================================================================
section "Symlinking dotfiles"

mkdir -p "$HOME/.config"

APPS=(fastfetch hypr kitty lazygit nvim spicetify spotify waybar zathura)

for app in "${APPS[@]}"; do
    source="$DOTFILES/$app"
    target="$HOME/.config/$app"

    if [ ! -d "$source" ]; then
        warn "Source $source not found, skipping"
        continue
    fi

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        warn "Backing up existing $target → $target.bak"
        mv "$target" "$target.bak"
    fi

    ln -sf "$source" "$target"
    success "Linked $app → $target"
done

# =============================================================================
# 18. POST-INSTALL STEPS
# =============================================================================
section "Post-install"

# xdg user dirs
xdg-user-dirs-update

# Spicetify: fix permissions and apply theme
if command -v spotify &>/dev/null && command -v spicetify &>/dev/null; then
    SPOTIFY_PATH=$(find /opt /usr/share -name "Apps" -path "*/spotify/*" 2>/dev/null | head -1)
    if [ -n "$SPOTIFY_PATH" ]; then
        sudo chmod a+wr "$SPOTIFY_PATH"
        sudo chmod a+wr -R "$SPOTIFY_PATH/."
    fi
    # Point spicetify config at our dotfiles spotify folder
    spicetify config spotify_path /usr/share/spotify 2>/dev/null || true
    spicetify backup apply 2>/dev/null && success "Spicetify applied" || warn "Spicetify apply failed — run manually after launching Spotify once"
fi

# Neovim: lazy.nvim will auto-install plugins on first launch
info "Neovim plugins will auto-install on first launch (lazy.nvim)"

# =============================================================================
# DONE
# =============================================================================
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║   Installation complete! Reboot or       ║${RESET}"
echo -e "${GREEN}${BOLD}║   log out and back in to start Hyprland. ║${RESET}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${CYAN}Next steps:${RESET}"
echo "  1. Reboot → select Hyprland from your display manager (or add it)"
echo "  2. If no display manager: add 'exec Hyprland' to ~/.bash_profile / ~/.zprofile"
echo "  3. Open Spotify once, then re-run: spicetify backup apply"
echo "  4. Open nvim — plugins will install automatically via lazy.nvim"
echo ""
