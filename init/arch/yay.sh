#!/bin/bash
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
if [[ $? == 0 ]]; then
	cd yay && makepkg -si
fi
