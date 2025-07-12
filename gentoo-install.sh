#!/bin/bash
# Tuomo Björk
# 2025-06-13

# System settings
DEP_GENTOO_PROFILE="default/linux/amd64/23.0/no-multilib/hardened/systemd"
DEP_TIMEZONE="Europe/Helsinki"
DEP_HOSTNAME="gentoo"

# Credentials for the new user
DEP_USER_NAME="user"
DEP_USER_PASS="123"
DEP_USER_SHELL="/bin/bash"


gentoo_install() {
# Prepare base system

	# Repository and profile
	emerge-webrsync
	eselect profile set "$GENTOO_PROFILE"

	# Timezone, locale
	ln -sf ../usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
	echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
	locale-gen
	eselect locale set en_US.utf8
	env-update && source /etc/profile

	# Portage
	if [[ -f "$PATH_DOTFILE/src/user/bin/portage-refresh" ]]; then
		source "$PATH_DOTFILE/src/bin/portage-refresh"
		portage_refresh
		if (( $? )); then
			echo "portage-refresh returned non-zero"
			exit 1
		fi
	else
		echo "missing 'portage-refresh' script"
		exit 1
	fi

	# Update system (brrr)
	# note: do in steps, gets closer to finish before issues crop up.
	local SETS_LS="$(ls /etc/portage/sets)"
	local SETS=$(printf "@%s " $SETS_LS)

	emerge -vuDN sys-kernel/linux-firmware
	echo "emerging: $SETS"
	emerge -vuDN @world
	emerge -vuDN @dot-base
	emerge -vuDN @dot-liblang
	emerge -vuDN @dot-utility
	emerge -vuDN @dot-desktop
	emerge -vuDN @dot-user
	emerge -vuDN @world $SETS
	if (( $? )); then
		echo -e "\nFix errors, retry."
		exit 1
	fi
	emerge -v --depclean
	echo ""
}

gentoo_boot() {
# Prepare ESP, initramfs, and fstab
	local UUID_ESP=$(blkid --match-token PARTLABEL=ESP --match-tag UUID | awk -F'"' '{print $2}')
	local UUID_LUKS=$(blkid --match-token PARTLABEL=LUKS --match-tag UUID | awk -F'"' '{print $2}')
	local UUID_ROOT=$(blkid --match-token LABEL=gentoo --match-tag UUID | awk -F'"' '{print $2}')

	# Boot manager
	bootctl --path=/efi install
	emerge --config gentoo-kernel

	# Initramfs
	mkdir -p /etc/dracut.conf.d
	cp "$HOME/dotfile/src/sys/etc/dracut.conf.d/luks.conf" /etc/dracut.conf.d/
	echo -e "\n# DRACUT"
	cat /etc/dracut.conf.d/luks.conf

	# Kernel CMDLINE
	mkdir -p /etc/kernel
	echo "rd.luks.uuid=$UUID_LUKS root=UUID=$UUID_ROOT quiet" > /etc/kernel/cmdline
	echo -e "\n# CMDLINE"
	cat /etc/kernel/cmdline

	# FSTAB
	rm -rf /etc/fstab
	echo "UUID=$UUID_ESP /efi vfat defaults,noatime,umask=0077 0 1" >> /etc/fstab
	echo "UUID=$UUID_ROOT / ext4 defaults,noatime 0 2" >> /etc/fstab

	# if 'portage-refresh' has set build to '/tmp' -> make it tmpfs
	grep -q '^PORTAGE_TMPDIR="/tmp"' /etc/portage/make.conf
	if (( ! $? )); then
		echo "tmpfs /tmp tmpfs defaults,mode=1777,size=$TMP_SIZE 0 0" >> /etc/fstab
	fi
	echo -e "\n# FSTAB"
	cat /etc/fstab
	echo ""
}

gentoo_finalise() {
# Finalise by setting up minimal system services, and a user

	# Machine ID & Hostname
	stat /etc/machine-id > /dev/null 2>&1
	if (( $? )); then
		systemd-machine-id-setup
	fi
	echo "$DEP_HOSTNAME" > /etc/hostname

	# Configurations
	cp "$PATH_DOTFILE/dotfile/src/sys/etc/chrony.conf" /etc/

	mkdir -p /etc/greetd
	cp "$PATH_DOTFILE/src/sys/etc/greetd/config.toml" /etc/greetd/


	# System services/sockets
	# note: 'systemctl list-unit-files'
	local SYS_DISABLE=(
		systemd-networkd.service     # Systemd networking
		systemd-timesyncd.service    # Systemd ntp
	)
	systemctl disable "${SYS_DISABLE[@]}"

	local SYS_ENABLE=(
		NetworkManager.service  # Networking
		chronyd.service         # NTP
		greetd.service          # Login manager
		cups.service            # Printing
		bluetooth.service       # Bluetooth
		tlp.service             # Battery management
		pcscd.service           # Smart-card
		pcscd.socket
	)
	systemctl enable "${SYS_ENABLE[@]}"


	# User services/sockets
	# note: 'systemctl --user list-unit-files'
	local USR_DISABLE=(
		waybar.service    # Wayland desktop panel service
	)
	systemctl --global disable "${USR_DISABLE}"

	local USR_ENABLE=(
		pipewire.service
		pipewire.socket
		pipewire-pulse.service
		wireplumber.service
		wireplumber.socket
		gpg-agent.service
		gpg-agent-ssh.service
		gpg-agent-extra.service
		mako.service
	)
	systemctl --global enable "${USR_ENABLE}"

	# User
	local USER_GROUPS="$(cat $PATH_DOTFILE/src/sys/groups)"

	id "$DEP_USER_NAME" > /dev/null
	if (( $? )); then
		useradd -m -s $DEP_USER_SHELL "$DEP_USER_NAME"
		echo "User created"
	else
		echo "User exists"
	fi
	usermod -aG $DEP_USER_GROUPS "$DEP_USER_NAME"
	echo "updated groups" ; groups "$DEP_USER_NAME"

	# Reset user password
	which chpasswd > /dev/null
	if (( $? )); then
		echo "chpasswd not in path, set \"$DEP_USER_NAME\" password manually!"
	else
		echo "$DEP_USER_NAME:$DEP_USER_PASS" | chpasswd > /dev/null 2>&1
		echo "credential reset - $DEP_USER_NAME:$DEP_USER_PASS"
		echo "REMEMBER TO CHANGE IT AFTERWARDS!"
	fi

	# Visudo fragments
	rm -rf /etc/sudoers.d
	mkdir -p /etc/sudoers.d
	cp "$PATH_DOTFILE"/src/sys/etc/sudoers.d/* /etc/sudoers.d/
	echo ""
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	echo -e "GENTOO SETUP (2 of 2)"
	echo -e "FOLLOW THE INSTRUCTIONS!\n"

	# Dotfile src is required for automatic deployment
	: "${PATH_DOTFILE:=$HOME/dotfile}"
	if [[ ! -d "$PATH_DOTFILE" ]]; then
		echo "missing dotfiles at $PATH_DOTFILE"
		echo "place them at indicated path, or set custom 'PATH_DOTFILE'"
		exit 1
	fi

	gentoo_install
	gentoo_boot
	gentoo_finalise
fi
