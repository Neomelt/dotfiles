#!/bin/bash
# One-shot setup script for a fresh Arch install.
# Run after: chezmoi init --apply git@github.com:Neomelt/dotfiles.git

set -e
REPO="$(cd "$(dirname "$0")" && pwd)"

# ── Packages ────────────────────────────────────────────────────────────────
echo "==> Installing packages..."
sudo pacman -S --needed \
  hyprland hyprlock hypridle hyprpaper \
  quickshell kitty \
  swaync \
  btop lazygit \
  fzf fd bat eza zoxide yazi \
  cliphist wl-clipboard \
  jq imagemagick ffmpeg \
  snapper snap-pac age \
  plymouth \
  chezmoi gh

# ── Plymouth theme ───────────────────────────────────────────────────────────
echo "==> Installing Plymouth theme..."
sudo mkdir -p /usr/share/plymouth/themes/dafeiyu
sudo cp "$REPO/plymouth/dafeiyu/"* /usr/share/plymouth/themes/dafeiyu/
sudo plymouth-set-default-theme -R dafeiyu

# ── Snapper ──────────────────────────────────────────────────────────────────
if ! sudo snapper -c root list &>/dev/null; then
  echo "==> Configuring snapper..."
  sudo snapper -c root create-config /
  sudo snapper -c root set-config \
    "TIMELINE_LIMIT_HOURLY=5" \
    "TIMELINE_LIMIT_DAILY=7" \
    "TIMELINE_LIMIT_WEEKLY=4" \
    "TIMELINE_LIMIT_MONTHLY=3" \
    "TIMELINE_LIMIT_YEARLY=2" \
    "NUMBER_LIMIT=20" \
    "NUMBER_LIMIT_IMPORTANT=5"
fi

echo ""
echo "Done. Reboot to see the Plymouth theme."
echo "Remember to restore ~/.config/chezmoi/age-key.txt if you have encrypted secrets."
