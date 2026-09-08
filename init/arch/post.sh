arch-chroot /mnt/ pacman -S --needed --noconfirm python-yaml

PKG_DIR="/mnt/tmp/dotfile/src/pkg"
PKG_LIST=$(python3 pkg.py "$PKG_DIR")

if [-n "$PKG_LIST" ]; then
	arch-chroot /mnt pacman -S --needed --noconfirm $PKG_LIST
fi
