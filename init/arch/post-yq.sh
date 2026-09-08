#!/bin/bash
PKG_DIR="/mnt/tmp/dotfile/src/pkg"

echo "==> Parsing package manifests from src/pkg/*.yml..."

# Extract 'arch' keys, split multi-package strings, deduplicate, and join into a single line
PKG_LIST=$(yq -r '.[].arch | select(. != null)' "$PKG_DIR"/*.yml 2>/dev/null \
    | tr -d '"'\' \
    | tr -s '[:space:]' '\n' \
    | grep -v '^$' \
    | sort -u \
    | tr '\n' ' ')

if [ -n "$PKG_LIST" ]; then
    echo "==> Installing extracted packages:"
    echo "$PKG_LIST"
    arch-chroot /mnt pacman -S --needed --noconfirm $PKG_LIST
else
    echo "==> No Arch packages found to install."
fi
