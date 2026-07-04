#!/bin/bash
# bootstrap.sh — Fedora 44 niri desktop setup from dotfiles repo
# Usage: ./bootstrap.sh [--system] [--fonts] [--icons]
#
# Flags:
#   --system   Also install system-level configs (greetd, vtrgb, systemd services) — needs sudo
#   --fonts    Also install Nerd Fonts from github (slower, ~100MB download)
#   --icons    Also install Gruvbox-Plus-Dark icon theme from github
#   --all      Do everything (--system --fonts --icons)
#
# Without flags, installs: dnf packages, wezterm nightly, yazi, dotfiles via stow,
# gsettings, wlogout icons, wallpapers. System configs and external assets are opt-in.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
THEME_WALLPAPER="gruvbox-dark.png"  # default wallpaper

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${GREEN}[+]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
err()  { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# Parse args
DO_SYSTEM=0
DO_FONTS=0
DO_ICONS=0

for arg in "$@"; do
  case "$arg" in
    --system) DO_SYSTEM=1 ;;
    --fonts)  DO_FONTS=1 ;;
    --icons)  DO_ICONS=1 ;;
    --all)    DO_SYSTEM=1; DO_FONTS=1; DO_ICONS=1 ;;
    *) err "Unknown flag: $arg" ;;
  esac
done

# ── Pre-flight ──────────────────────────────────────────────────────────────
[[ "$(id -u)" -ne 0 ]] || err "Run as your user, not root."

if ! grep -q "Fedora" /etc/os-release 2>/dev/null; then
  warn "This script targets Fedora. Proceed at your own risk."
fi

# ── 1. DNF packages ─────────────────────────────────────────────────────────
log "Installing dnf packages..."

# Core desktop
sudo dnf install -y \
  niri waybar fuzzel mako swaybg swaylock swayidle slurp \
  brightnessctl lxpolkit wlogout cliphist \
  grim wl-clipboard playerctl \
  tuigreet greetd greetd-selinux \
  xdg-desktop-portal xdg-desktop-portal-gnome xdg-desktop-portal-gtk \
  pipewire wireplumber \
  adw-gtk3-theme jetbrains-mono-fonts \
  stow git fd-find fzf \
  blueman network-manager-applet nm-connection-editor \
  tesseract tesseract-langpack-eng \
  tuned tuned-ppd

# Development tools
sudo dnf install -y \
  ripgrep bat eza zoxide 2>/dev/null || warn "Some dev tools not in repos (non-fatal)"

# Enable tuned
sudo systemctl enable --now tuned

log "DNF packages done."

# ── 2. WezTerm nightly ──────────────────────────────────────────────────────
if ! command -v wezterm &>/dev/null; then
  log "Installing WezTerm nightly from GitHub releases..."
  WEZTERM_RPMS=(wezterm-common wezterm-gui wezterm-mux-server)
  TMPDIR_WEZTERM=$(mktemp -d)
  for pkg in "${WEZTERM_RPMS[@]}"; do
    curl -fsSL -o "$TMPDIR_WEZTERM/${pkg}.rpm" \
      "https://github.com/wez/wezterm/releases/download/nightly/${pkg}-nightly-fedora41.rpm"
  done
  sudo dnf install -y --nogpgcheck "$TMPDIR_WEZTERM"/*.rpm
  rm -rf "$TMPDIR_WEZTERM"
  log "WezTerm installed."
else
  log "WezTerm already installed, skipping."
fi

# ── 3. Yazi ─────────────────────────────────────────────────────────────────
if ! command -v yazi &>/dev/null; then
  log "Installing Yazi from GitHub releases..."
  YAZI_VERSION="26.5.6"
  ARCH=$(uname -m)
  YAZI_URL="https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-x86_64-unknown-linux-gnu.zip"
  TMPDIR_YAZI=$(mktemp -d)
  curl -fsSL -o "$TMPDIR_YAZI/yazi.zip" "$YAZI_URL"
  unzip -o "$TMPDIR_YAZI/yazi.zip" -d "$TMPDIR_YAZI"
  install -Dm755 "$TMPDIR_YAZI/yazi-x86_64-unknown-linux-gnu/yazi" ~/.local/bin/yazi
  rm -rf "$TMPDIR_YAZI"
  log "Yazi installed to ~/.local/bin/yazi"
else
  log "Yazi already installed, skipping."
fi

# ── 4. Nerd Fonts (opt-in) ──────────────────────────────────────────────────
if [[ "$DO_FONTS" -eq 1 ]]; then
  log "Installing FiraCode Nerd Font..."
  mkdir -p ~/.local/share/fonts
  TMPDIR_FONTS=$(mktemp -d)
  curl -fsSL -o "$TMPDIR_FONTS/FiraCode.zip" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
  unzip -o "$TMPDIR_FONTS/FiraCode.zip" -d ~/.local/share/fonts
  rm -rf "$TMPDIR_FONTS"
  fc-cache -f
  log "Nerd Fonts installed."
else
  # Use bundled fonts from dotfiles repo
  if [[ -d "$DOTFILES_DIR/fonts" ]]; then
    log "Installing FiraCode Nerd Font from dotfiles repo..."
    mkdir -p ~/.local/share/fonts
    cp "$DOTFILES_DIR/fonts/.local/share/fonts/"*.ttf ~/.local/share/fonts/
    fc-cache -f
    log "Fonts installed from repo."
  fi
fi

# ── 5. Gruvbox-Plus-Dark icon theme (opt-in) ────────────────────────────────
if [[ "$DO_ICONS" -eq 1 ]]; then
  log "Installing Gruvbox-Plus-Dark icon theme..."
  TMPDIR_ICONS=$(mktemp -d)
  git clone --depth 1 https://github.com/PapirusDevelopmentTeam/gruvbox-plus-icon-pack "$TMPDIR_ICONS"
  cp -r "$TMPDIR_ICONS/Gruvbox-Plus-Dark" ~/.local/share/icons/
  cp -r "$TMPDIR_ICONS/Gruvbox-Plus-Light" ~/.local/share/icons/
  rm -rf "$TMPDIR_ICONS"
  log "Icon theme installed."
else
  warn "Skipping icon theme install. Use --icons to install Gruvbox-Plus-Dark."
  warn "Without it, gsettings icon-theme will have no icons."
fi

# ── 6. Dotfiles via GNU Stow ────────────────────────────────────────────────
log "Stowing dotfile packages..."
cd "$DOTFILES_DIR"

STOW_PACKAGES=(
  niri waybar wezterm fuzzel mako swaylock wlogout yazi bash git bin
  xdg-desktop-portal wallpapers fonts wlogout-icons dconf
)

for pkg in "${STOW_PACKAGES[@]}"; do
  if [[ -d "$pkg" ]]; then
    stow -R "$pkg" 2>/dev/null || warn "Stow $pkg had conflicts (may need manual fix)"
  fi
done

log "Dotfiles stowed."

# ── 7. Gsettings ────────────────────────────────────────────────────────────
log "Applying gsettings (GTK theme, icons, fonts, cursor)..."

# Apply settings from the dconf stow package
SETTINGS_FILE="$DOTFILES_DIR/dconf/.config/gsettings-interface.txt"
if [[ -f "$SETTINGS_FILE" ]]; then
  while IFS= read -r line; do
    SCHEMA=$(echo "$line" | awk '{print $1}')
    KEY=$(echo "$line" | awk '{print $2}')
    VALUE=$(echo "$line" | awk '{print $3}' | sed "s/^'//;s/'$//")
    gsettings set "$SCHEMA" "$KEY" "$VALUE" 2>/dev/null || true
  done < "$SETTINGS_FILE"
fi

# Critical settings (in case the dump format is tricky to parse)
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Gruvbox-Plus-Dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
gsettings set org.gnome.desktop.interface cursor-size 24
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface font-name 'Adwaita Sans 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'Adwaita Mono 11'

log "Gsettings applied."

# ── 8. Screenshots directory ────────────────────────────────────────────────
mkdir -p ~/Pictures/Screenshots

# ── 9. Hostname ─────────────────────────────────────────────────────────────
if [[ "$(hostname)" != "fedora-niri" ]]; then
  log "Setting hostname to fedora-niri..."
  sudo hostnamectl set-hostname fedora-niri
fi

# ── 10. System-level configs (opt-in, needs sudo) ───────────────────────────
if [[ "$DO_SYSTEM" -eq 1 ]]; then
  log "Installing system-level configs..."

  # greetd config
  if [[ -f "$DOTFILES_DIR/system-config/etc/greetd/config.toml" ]]; then
    sudo mkdir -p /etc/greetd
    sudo cp "$DOTFILES_DIR/system-config/etc/greetd/config.toml" /etc/greetd/config.toml
    sudo systemctl enable greetd.service
    log "greetd configured with tuigreet."
  fi

  # vtrgb Nord palette
  if [[ -f "$DOTFILES_DIR/system-config/etc/vtrgb" ]]; then
    sudo cp "$DOTFILES_DIR/system-config/etc/vtrgb" /etc/vtrgb
    sudo cp "$DOTFILES_DIR/system-config/etc/systemd/system/vtrgb-nord.service" \
      /etc/systemd/system/vtrgb-nord.service
    sudo systemctl enable vtrgb-nord.service
    log "Nord VT palette installed."
  fi

  # Disable default display manager if not greetd
  if systemctl is-enabled cosmic-greeter.service &>/dev/null; then
    sudo systemctl disable cosmic-greeter.service
  fi
  if systemctl is-enabled gdm.service &>/dev/null; then
    sudo systemctl disable gdm.service
  fi

else
  warn "Skipping system configs. Use --system to install greetd, vtrgb, etc."
  warn "Without --system, you'll need to configure greetd manually."
fi

# ── 11. DCONF profile cleanup ───────────────────────────────────────────────
# Remove leftover COSMIC dconf profile if present
rm -f ~/.config/dconf/cosmic 2>/dev/null || true

# ── Done ────────────────────────────────────────────────────────────────────
echo ""
log "Bootstrap complete!"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Reboot to start your niri session via greetd/tuigreet"
echo "  2. Select 'niri' at the tuigreet session picker"
echo "  3. Mod+T opens wezterm, Mod+D opens fuzzel"
echo "  4. Mod+Shift+Slash shows the keybinding overlay"
echo ""
if [[ "$DO_SYSTEM" -eq 0 ]]; then
  echo -e "${YELLOW}Note: Run with --system to configure greetd/tuigreet as display manager.${NC}"
fi
if [[ "$DO_ICONS" -eq 0 ]]; then
  echo -e "${YELLOW}Note: Run with --icons to install Gruvbox-Plus-Dark icon theme.${NC}"
fi