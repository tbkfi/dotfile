#!/bin/bash
BLOCK_TARGET=""		# Set by function
BLOCK_SIZE_GB=""	# Set by function
BLOCK_SIZE_GB_MIN="30"	# Set to '0' to force
LUKS_OPTS="--type luks2 --sector-size=4096"

ESP_TARGET=""	# Set by function
LUKS_TARGET=""	# Set by function

# Path to fetch dotfiles from, default path is internal-use only!
DOTFILE_URL="https://git.lan.tbk.fi/tbk/dotfile.git"


msg_err() {
# Print an error
	echo "\n* ERROR: $@ !\n" >&2
}

abort() {
# Exit message and exit
	echo -e "\nExiting ..."
	exit 1
}

confirm_wait() {
# Wait for $1 seconds, print $2, and give user chance to abort.
	local WAIT_TIME_S="$1"
	local MESSAGE="$2"

	# Message
	echo -e "\n$2 !!!"

	# Wait and print counter
	for (( i=$WAIT_TIME_S; i > 0; i-- )); do
		echo -n "$i "

		# If stdin -> abort
		read -t 1 -n 1 key
		if (( ! $? )); then
			msg_err "Aborted by user keypress"
			abort
		fi

	done
	echo -e "\n"
}

dotfile_path() {
# Ask the user if dotfile source path is correct
	local SRC_PATH=""

	# Ask the user
	echo -e "* This script depends on the dotfiles for system setup,"
	echo -e "  please verify the below path is correct before proceeding!\n"
	echo -e "$DOTFILE_URL\n"
	read -p "Enter new path now (or ENTER to continue): " SRC_PATH

	# Set new path, if provided
	if [[ "$SRC_PATH" != "" ]]; then
		DOTFILE_URL="$SRC_PATH"
		echo -e "new path set: $DOTFILE_URL\n"
	else
		echo -e "preserving default path\n"
	fi
}

disk_ask() {
# Ask for target system disk.
	echo -e "\n$(lsblk -d -o PATH,SIZE)\n"

	while true; do
		read -p "Enter system disk path (will be erased!): "  BLOCK_TARGET

		# Verify path exists
		if [[ -b "$BLOCK_TARGET" ]]; then
			BLOCK_SIZE_GB="$(lsblk -n -b -d -o PATH,SIZE | grep "$BLOCK_TARGET" | awk '{print $2}')"

			# Convert to gibibytes
			(( BLOCK_SIZE_GB = $BLOCK_SIZE_GB / 1024**3 ))

			# Check for minimum requirements (~30GiB as of writing)
			if (( $BLOCK_SIZE_GB < $BLOCK_SIZE_GB_MIN )); then
				msg_err "Disk capacity is less than minimum required (${BLOCK_SIZE_GB_MIN}GB)"
				abort
			else
				break # Proceed
			fi
		else
			echo "Disk path ('$BLOCK_TARGET') is invalid!"
		fi
	done

	# Try to set here, if script was previously interrupted
	ESP_TARGET="$(blkid --match-token PARTLABEL=ESP | awk -F: '{print $1}')"
	LUKS_TARGET="$(blkid --match-token PARTLABEL=LUKS | awk -F: '{print $1}')"

	# Print details
	echo "system-drive-path: $BLOCK_TARGET"
	echo "system-drive-size: ${BLOCK_SIZE_GB}GB"
	echo ""
}

unmount_disk() {
# Unmount target disk (forceful).
	echo -e "\nAttempting to unmount target disk ..."
	umount -l "/mnt/gentoo/efi"
	umount -l "/mnt/gentoo"
	umount -l "$BLOCK_TARGET"
	echo ""
}

disk_erase() {
# Format target system disk.

	# Disk should not be mounted
	cd ; unmount_disk
	if (( $? != 0 && $? != 32 && $? != 130 )); then
		msg_err "Unable to unmount target disk before erasing"
		abort
	fi
	cryptsetup close /dev/mapper/cryptroot > /dev/null 2>&1

	# Chance to abort
	confirm_wait 10 "About to erase disk"

	# Wiping a contemporary disk isn't quite so simple for various reasons,
	# but this ought to introduce at least SOME entropy before we begin.
	echo "Writing via \"/dev/urandom\" (1 of 2)..."
	dd if="/dev/urandom" of="$BLOCK_TARGET" bs=1M status=progress
	echo "Writing via \"/dev/zero\" (2 of 2)..."
	dd if="/dev/zero" of="$BLOCK_TARGET" bs=4M status=progress
}

disk_format() {
# Partition target system disk for ESP and ROOT (LUKS).

	# Label and partitions
	parted -s "$BLOCK_TARGET" mklabel gpt
	parted -s --align optimal "$BLOCK_TARGET" mkpart ESP "1MiB" "1025MiB"
	parted -s --align optimal "$BLOCK_TARGET" mkpart LUKS "1025MiB" 100%
	parted -s "$BLOCK_TARGET" set 1 esp on # flags are set to dev, not partition!

	# Disk partition paths
	ESP_TARGET="$(blkid --match-token PARTLABEL=ESP | awk -F: '{print $1}')"
	LUKS_TARGET="$(blkid --match-token PARTLABEL=LUKS | awk -F: '{print $1}')"

	# Chance to abort
	echo "esp-part: $ESP_TARGET"
	echo "luks-part: $LUKS_TARGET"
	confirm_wait 10 "About to partition disk"

	# Cryptsetup: luksFormat
	cryptsetup luksFormat "$LUKS_TARGET" $LUKS_OPTS
	if (( $? )); then
		msg_err "Something went wrong during luksFormat"
		abort
	fi

	# Cryptsetup: Mount new LUKS crypt
	echo -e "\nOpening newly created LUKS device ..."
	cryptsetup luksOpen "$LUKS_TARGET" cryptroot
	if (( $? )); then
		msg_err "Something went wrong during luksOpen"
		abort
	fi

	# Make filesystems
	echo "Formatting ESP and ROOT"
	mkfs.fat -F 32 "$ESP_TARGET"
	mkfs.ext4 -L "gentoo" /dev/mapper/cryptroot
}

download_stage3() {
# Try to download the latest stage3 tarfile.

	# Example tarball url:
	# https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-nomultilib-systemd/stage3-amd64-nomultilib-systemd-20250622T165243Z.tar.xz
	local URL_BASE="https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-nomultilib-systemd"
	local TARBALL=$(curl -s "$URL_BASE/" | grep -oP 'stage3-amd64-nomultilib-systemd-\d+T\d+Z\.tar\.xz' | sort -r | head -n1)
	local URL_FULL="$URL_BASE/$TARBALL"

	echo "Tried to find appropriate file(s) ..."
	echo "* FROM: $URL_FULL"
	echo "* TARBALL: $TARBALL"
	confirm_wait 10 "About to start download"

	# Download
	curl --user-agent "Links (2.29; Linux x86_64; text)" -O "${URL_FULL}.sha256"
	curl --user-agent "Links (2.29; Linux x86_64; text)" -O "$URL_FULL"
	if (( $? )); then
		msg_err "TARBALL download failed"
		abort
	fi

	# Verify hash
	echo "Attempting to verify against HASH ..."
	grep -A1 'SHA256 HASH' "${TARBALL}.sha256" | tail -n1 | sha256sum -c -
	if (( $? )); then
		msg_err "TARBALL verification failed"
		abort
	fi

	# Verify gpg (todo)
}

disk_mount() {
# Try to mount disk ($1) to path ($2)
	echo "Mounting \"$1\" to \"$2\""
	mount "$1" "$2"
	if (( $? )); then
		msg_err "Failed to mount"
		abort
	fi
}

deploy_stage3() {
# Create the base environment from stage3 source
	cd ; unmount_disk

	# Mount partitions
	mkdir -p "/mnt/gentoo"
	disk_mount "/dev/mapper/cryptroot" "/mnt/gentoo"

	mkdir -p "/mnt/gentoo/efi"
	disk_mount "$ESP_TARGET" "/mnt/gentoo/efi"

	# Stage3
	rm -rf "/mnt/gentoo"
	cd "/mnt/gentoo"
	download_stage3
	tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner -C "/mnt/gentoo"
	cp --dereference /etc/resolv.conf "/mnt/gentoo/etc/"

	echo -e "\nCHECKPOINT CHECKPOINT CHECKPOINT"
	echo -e "CHECKPOINT CHECKPOINT CHECKPOINT"
	echo -e "CHECKPOINT CHECKPOINT CHECKPOINT\n\n"
	echo "* Continue installation inside chroot:"
	echo ">> arch-chroot /mnt/gentoo"

	# Clone dotfiles
	git clone "$DOTFILE_URL" "/mnt/gentoo/root/dotfile" > /dev/null 2>&1
	if (( $? )); then
		echo "* Failed cloning dotfiles to /mnt/gentoo/root/dotfile !"
		echo "* Obtain them manually to continue via gentoo-install.sh,"
		echo "  or install everything manually!"
	else
		echo "* Cloned dotfiles to /mnt/gentoo/root/dotfile"
		echo "* Continue install: cd /mnt/gentoo/root/dotfile && bash gentoo-install.sh"
	fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	echo -e "GENTOO SETUP (1 of 2)"
	echo -e "FOLLOW THE INSTRUCTIONS!\n"

	dotfile_path
	if [[ $BLOCK_TARGET == "" ]]; then disk_ask; fi
	disk_erase
	disk_format
	deploy_stage3
fi
