# Dotfile

Versioned dotfiles for my Gentoo workstation. The configuration files are
expected to work in other distributions using same system components,
although they aren't much tested elsewhere on the regular.

Base system profile is `no-multilib/hardened/systemd`, and `-X` is enabled
globally. Other packages are tracked in `/src/pkg` directory, and include matches for Debian, Fedora, and
Arch in addition to Gentoo.

Below is the expected `$HOME` structure for the working user...

```
 $HOME
 ├─ .config
 ├─ .local
 ├─ dotfile <- sticky!
 ├─ local
 │  ├─ desktop
 │  ├─ document
 │  ├─ download
 │  ├─ music
 │  ├─ picture
 │  ├─ public
 │  ├─ template
 │  └─ video
 └─ remote
    └─ {_netdev}
```

## Features

Lean 64-bit only Linux desktop on Sway. One-step deployment of desired user
packages, versioned configurations, and strong glyph support. 

Sensible structure and symbolic links make versioning all user-configuration
easy and consistent, preventing loss of important workflow details that are made
as time passes. Modular structure makes extending the scope easy and consistent,
if needed.

Crossdev support for tooling and workflow is still WIP, with a focus on ARM and
C/C++.

## Deployment

### Dotfiles
Using these dotfiles is as simple as installing the packages in `/src/pkg`,
cloning the repository to a user's home directory, and running the
`/src/user/bin/dot-refresh` in BASH as the user.

### Gentoo deployment scripts

The deployment is split into two scripts (`gentoo-prepare.sh` and `gentoo-install.sh`).
Both are designed to be ran attended from a Gentoo livecd, and will result in a
bootable installation (unless things break, which they do).

The scripts are essentially a streamlined version of the official
[Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:Main_Page) for the settings that I happen to like.

The `gentoo-prepare.sh` script will:
1. Prompt for system disk
2. Erase system disk
3. Partition system disk (ESP:1GiB, LUKS:100%Free)
4. Format system disk (fat32, ext4)
5. Mount new filesystems
6. Fetch latest Gentoo stage 3 tarball
7. Extract and deploy tarball to new filesystem
8. Copy existing resolver configuration to new system
9. Clone these dotfiles to the new filesystem
10. Instruct the user on how to proceed

The `gentoo-install.sh` script will:
1. Sync repositories and set system profile
2. Set timezone and locale
3. Setup Portage (global, package) flags
4. Determine appropriate jobs and load-average values
5. Conditionally move build dir into tmpfs (thread & ram dependant)
5. Enable appropriate system cpu flags
6. Emerge world, in steps to avoid conflicts
7. Configure Boot Manager (systemd-boot)
8. Setup initramfs for LUKS (Dracut)
9. Setup cmdline parameters for LUKS
10. Create appropriate fstab
11. Systemd setup (incl. system and user services)
12. Create working user (and enable sudo)
13. Reboot into new system

### Submodules
Certain submodules in this repository are restricted use, and they can be safely ignored
by people with no access. They are linked purely for the author's convenience and reside on
an upstream server in a separate secure network.

## License
All code and assets, unless otherwise stated, are licensed under the \
GNU General Public License v3.0 – see the [LICENSE](./LICENSE) file for details.
