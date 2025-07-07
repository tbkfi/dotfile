#!/bin/bash
GENTOO_PROFILE="default/linux/amd64/23.0/no-multilib/hardened/systemd"
TIMEZONE="Europe/Helsinki"

THREAD_COUNT=""		# Set by helper
LOAD_MAX=""		# Set by helper
MEMORY_TOTAL=""		# Set by helper


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
	rm -rf /etc/portage/package.{use,license,mask,unmask,accept_keyword}
	mkdir /etc/portage/package.{use,license,mask,unmask,accept_keyword}
	cp $HOME/dotfile/src/sys/etc/portage/make.conf /etc/portage/make.conf

	emerge -uDN app-portage/cpuid2cpuflags
	echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags # https://wiki.gentoo.org/wiki/CPU_FLAGS_*

	portage_refresh
	portage_build_load

	# Update system
	# note: do in steps, helps to get closer before manual intervention
	# is required if something is broken (or avoids issues: e.g. go-bootstrap).
	local SETS_LS="$(ls /etc/portage/sets)"
	local SETS=$(printf "@%s " $SETS_LS)

	emerge -vuDN sys-kernel/linux-firmware
	echo "emerging: $SETS"
	emerge -avuDN @world
	emerge -avuDN @dot-base
	emerge -avuDN @dot-liblang
	emerge -avuDN @dot-utility
	emerge -avuDN @dot-desktop
	emerge -avuDN @dot-user
	emerge -avuDN $SETS
	if (( $? )); then
		echo "Fix errors, retry."
		exit 1
	fi
	emerge -av --depclean
	echo ""
}

gentoo_boot() {
# Prepare ESP, initramfs, and fstab
	local UUID_ESP=$(blkid --match-token PARTLABEL=ESP --match-tag UUID | awk -F'"' '{print $2}')
	local UUID_LUKS=$(blkid --match-token PARTLABEL=LUKS --match-tag UUID | awk -F'"' '{print $2}')
	local UUID_ROOT=$(blkid --match-token LABEL=gentoo --match-tag UUID | awk -F'"' '{print $2}')
	local TMP_SIZE=0

	# Condition for mounting /tmp in ram
	if (( $MEMORY_TOTAL - $THREAD_COUNT * 2 >= 32 )); then
		TMP_SIZE=32
		echo "Enough ram for /tmp"
	fi

	# Boot manager
	bootctl --path=/efi install
	emerge --config gentoo-kernel-bin

	# Initramfs
	mkdir -p /etc/dracut.conf.d
	cp "$HOME/dotfile/src/sys/etc/dracut.conf.d/luks.conf" /etc/dracut.conf.d/
	echo -e "\n# DRACUT"
	cat /etc/dracut.conf.d/luks.conf

	# Kernel CMDLINE
	mkdir -p /etc/kernel
	echo "rd.luks.uuid=$UUID_LUKS root=UUID=$UUID_ROOT" > /etc/kernel/cmdline
	echo -e "\n# CMDLINE"
	cat /etc/kernel/cmdline

	# FSTAB
	rm -rf /etc/fstab
	echo "UUID=$UUID_ESP /efi vfat defaults,noatime,umask=0077 0 1" >> /etc/fstab
	echo "UUID=$UUID_ROOT / ext4 defaults,noatime 0 2" >> /etc/fstab
	if (( $TMP_SIZE )); then
		echo "tmpfs /tmp tmpfs defaults,mode=1777,size=$TMP_SIZE 0 0" >> /etc/fstab
	fi
	echo -e "\n# FSTAB"
	cat /etc/fstab
	echo ""
}

gentoo_finalise() {
# Finalise by setting up minimal system services, and a user

	# Machine ID & Hostname
	stat /etc/machine-id > /dev/null
	if (( $? )); then
		systemd-machine-id-setup
	fi
	echo "gentoo" > /etc/hostname

	# System configurations
	cp $HOME/dotfile/src/sys/etc/chrony.conf /etc/

	mkdir -p /etc/greetd
	cp $HOME/dotfile/src/sys/etc/greetd/config.toml /etc/greetd/


	# System services/sockets
	# note: 'systemctl list-unit-files'
	local SYS_DISABLE=(
		systemd-networkd.service	# Systemd networking
		systemd-timesyncd.service       # Systemd ntp
	)
	systemctl disable "${SYS_DISABLE[@]}"

	local SYS_ENABLE=(
		NetworkManager.service  # Networking
		chronyd.service	 # NTP
		greetd.service	  # Login manager
		cups.service	    # Printing
		bluetooth.service       # Bluetooth
		tlp.service	     # Battery management
		pcscd.service	   # Smart-card
		pcscd.socket
	)
	systemctl enable "${SYS_ENABLE[@]}"


	# User services/sockets
	# note: 'systemctl --user list-unit-files'
	local USR_DISABLE=(
		waybar.service	  # Wayland desktop panel service
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
	local USER_NAME="user"
	local USER_PASS="123"
	local USER_SHELL="/bin/bash"
	local USER_GROUPS="$(cat $HOME/dotfile/src/sys/groups)"

	id "$USER_NAME" > /dev/null
	if (( $? )); then
		useradd -m -s $USER_SHELL "$USER_NAME"
		echo "User created"
	else
		echo "User exists"
	fi
	usermod -aG $USER_GROUPS "$USER_NAME"
	echo "updated groups" ; groups "$USER_NAME"

	# Reset user password
	which chpasswd > /dev/null
	if (( $? )); then
		echo "chpasswd not in path, set \"$USER_NAME\" password manually!"
	else
		echo "$USER_NAME:$USER_PASS" | chpasswd > /dev/null 2>&1
		echo "credential reset - $USER_NAME:$USER_PASS"
		echo "REMEMBER TO CHANGE IT AFTERWARDS!"
	fi

	# Visudo fragments
	rm -rf /etc/sudoers.d
	mkdir -p /etc/sudoers.d
	cp $HOME/dotfile/src/sys/etc/sudoers.d/* /etc/sudoers.d/
	echo ""
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	echo -e "GENTOO SETUP (2 of 2)"
	echo -e "FOLLOW THE INSTRUCTIONS!\n"

	gentoo_install
	gentoo_boot
	gentoo_finalise
fi
