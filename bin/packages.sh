#!/bin/ksh -
set -Cefuo pipefail

if [[ "$(id -u)" != '0' ]]; then
	printf "EPERM: must be run as root\n"
	exit 1
fi

OS=$(uname); export OS

case ${OS} in
	Linux)
		if [[ -r /etc/alpine-release ]]; then
			apk add \
				atop \
				bat \
				curl \
				doas \
				docs \
				dosfstools \
				fd \
				file \
				git \
				helix \
				less \
				loksh \
				lsblk \
				make \
				mandoc-apropos \
				ncdu \
				pciutils \
				plocate \
				procps \
				ripgrep \
				rsync \
				tig \
				tmux \
				util-linux-misc
			if lspci 2>/dev/null | grep -i virtio; then
				# install drivers for OpenBSD's vmm(4) + a graphical desktop
				apk add \
					adwaita-icon-theme \
					adwaita-xfce-icon-theme \
					alacritty \
					flatpak \
					mesa-dri-gallium \
					mesa-utils \
					mesa-vulkan-swrast \
					virtio_vmmci-virt \
					vmm_clock-virt \
					xdg-desktop-portal-gnome \
					xdg-desktop-portal-gtk \
					xdg-user-dirs \
					xf86-input-libinput \
					xfce4 \
					xorg-server \
					xrdp
			else
				# otherwise we're running on physical hardware
				apk add fwupd \
					hwinfo
			fi
		fi
		;;
	OpenBSD)
		pkg_add \
			bat-- \
			delta-- \
			fd-- \
			git-- \
			helix-- \
			lynx-- \
			ncdu-- \
			pre-commit-- \
			py3-mypy-- \
			python--%3 \
			ripgrep-- \
			shellcheck-- \
			sysclean--
		if rcctl ls on | grep xenodm; then
			pkg_add \
				alacritty-- \
				codenewroman-nerd-fonts-- \
				dino-- \
				exfat-fuse-- \
				exiv2-- \
				fira-fonts-- \
				firefox-- \
				gnumeric-- \
				iosevka-slab-- \
				juliamono-- \
				keepassxc-- \
				liberation-fonts-- \
				libinput-openbsd-- \
				lyx-- \
				mpv-- \
				mupdf-- \
				openmoji-- \
				remmina-- \
				scrot-- \
				sct-- \
				texlive_texmf-full-- \
				ungoogled-chromium-- \
				xscreensaver-- \
				xwallpaper--
		else
			pkg_add \
				newsboat-- \
				zola
		fi
		;;
esac
