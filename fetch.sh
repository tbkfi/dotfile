#!/usr/bin/env bash
# Gemini. Temporary. Setupfile
set -euo pipefail

REPO_URL="https://github.com/tbkfi/dotfile.git"
TARBALL_URL="https://github.com/tbkfi/dotfile/archive/refs/heads/main.tar.gz"
TARGET_DIR="/tmp/dotfile"
INIT_DIR="$TARGET_DIR/init"

## TODO: Preamble, should be for each distro, with guards.
# Arch:
# 'pacman -Sy'
# 'pacman -S git archinstall'
# 'git switch vai-ws'
# 'git pull https://github.com/tbkfi/dotfile.git vai-ws'
pacman -Sy --noconfirm --needed
pacman -S --noconfirm --needed git archinstall

echo "==> Fetching repository to $TARGET_DIR..."
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"

if command -v git >/dev/null 2>&1; then
    git clone --depth 1 "$REPO_URL" "$TARGET_DIR"
else
    curl -sSL "$TARBALL_URL" | tar -xz -C "$TARGET_DIR" --strip-components=1
fi

if [ -d "$INIT_DIR" ]; then
    echo "==> Moving to $INIT_DIR..."

    # TEMP
    cd "$TARGET_DIR"
    git switch vai-ws
    git pull https://github.com/tbkfi/dotfile.git vai-ws
    # TEMP
    
    cd "$INIT_DIR"
    # Spawns a new subshell in the init directory so your shell stays there after execution
    exec "${SHELL:-/bin/bash}"
else
    echo "Error: Directory $INIT_DIR does not exist." >&2
    exit 1
fi
