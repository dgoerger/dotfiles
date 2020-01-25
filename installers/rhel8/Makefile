# Red Hat Enterprise Linux 8: Workstation
# Last tested: 19 September 2019

check:
	sudo sshd -t -f sshd_config
	sudo visudo --check --quiet -f sudoers
	sudo unbound-checkconf -f unbound.conf >/dev/null

nvidia:
	# note: dkms is in the EPEL repository
	sudo yum -qy install dkms elfutils-libelf-devel kernel-devel
	sudo systemctl enable --now dkms
	sudo mkdir -p /usr/local/tmp
	if [[ ! -f /usr/local/src/nvidia-440.44.run ]]; then sudo curl -sLo /usr/local/src/nvidia-440.44.run 'https://us.download.nvidia.com/XFree86/Linux-x86_64/440.44/NVIDIA-Linux-x86_64-440.44.run'; fi
	if [[ ! -d /var/lib/dkms/nvidia/440.44 ]]; then sudo sh /usr/local/src/nvidia-440.44.run --accept-license --no-questions --dkms --tmpdir /usr/local/tmp --silent; fi

install:
	## remove and disable unnecessary things
	sudo yum -qy remove PackageKit-command-not-found baobab cheese eog evince evolution firefox gedit gnome-boxes gnome-calculator gnome-font-viewer gnome-logs pidgin rhythmbox setroubleshoot subscription-manager-cockpit totem yelp
	sudo systemctl --quiet disable --now atd
	sudo systemctl --quiet disable --now avahi-daemon.service
	sudo systemctl --quiet disable --now avahi-daemon.socket
	sudo systemctl --quiet disable --now bolt
	sudo systemctl --quiet disable --now crond
	sudo systemctl --quiet disable --now cups.service
	sudo systemctl --quiet disable --now cups.socket
	sudo systemctl --quiet disable --now cups.path
	sudo systemctl --quiet disable --now kdump
	sudo systemctl --quiet disable --now ModemManager
	sudo systemctl --quiet disable --now rpcbind
	sudo systemctl --quiet disable --now rpcbind.socket
	sudo systemctl --quiet disable --now systemd-resolved.service
	sudo systemctl --quiet mask fprintd
	sudo systemctl --quiet mask geoclue
	sudo systemctl --quiet mask rpcbind
	sudo systemctl --quiet mask rpcbind.socket
	sudo touch /etc/cron.allow
	# only allow SSH by default
	sudo firewall-cmd --quiet --set-default-zone=dmz
	sudo firewall-cmd --quiet --lockdown-on
	## enable EPEL
	if [[ ! -f /etc/yum.repos.d/epel.repo ]]; then sudo yum -qy install epel-release 2>/dev/null || sudo yum -qy install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm; fi
	## install useful utilities
	sudo yum -qy install atop bpftrace gdb mg ncdu podman-docker qemu-img sysstat tmux
	sudo systemctl --quiet enable atop.service
	# install GNOME extensions and Tweaks
	sudo yum -qy install gnome-shell-extension-dash-to-dock gnome-shell-extension-native-window-placement gnome-shell-extension-no-hot-corner gnome-tweaks
	# enable flatpaks from Flathub.org
	sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	## copy confs
	# chrony time daemon
	sudo install -C -Z -o root -g root -m 0444 chrony.conf /etc/chrony.conf
	# firefox
	if [[ -d /usr/lib64/firefox/distribution ]]; then sudo install -C -Z -o root -g root -m 0444 firefox.json /usr/lib64/firefox/distribution/policies.json; fi
	# google-chrome
	if [[ ! -f /usr/bin/google-chrome ]]; then sudo yum -qy install https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm; fi
	# mandb/makewhatis
	sudo install -C -Z -o root -g root -m 0444 makewhatis.timer /etc/systemd/system/makewhatis.timer
	sudo systemctl --quiet daemon-reload
	sudo systemctl --quiet enable makewhatis.timer
	# mlocate
	sudo systemctl --quiet enable --now mlocate-updatedb.timer
	# NetworkManager
	sudo install -C -Z -o root -g root -m 0444 NetworkManager.conf /etc/NetworkManager/NetworkManager.conf
	# OpenSSH
	sudo install -C -Z -o root -g root -m 0444 sshd_config /etc/ssh/sshd_config
	# patchall script
	sudo install -C -Z -o root -g root -m 0544 patchall.sh /usr/local/sbin/patchall
	# polkit authorization policies
	sudo install -C -Z -o root -g root -m 0444 polkit_permit-usbs.rules /etc/polkit-1/rules.d/15-permit-usbs.rules
	sudo install -C -Z -o root -g root -m 0444 polkit_prohibit-shutdown.rules /etc/polkit-1/rules.d/55-prohibit-shutdown.rules
	# tmpfs on /tmp
	sudo install -C -Z -o root -g root -m 0444 tmp.mount /etc/systemd/system/tmp.mount
	sudo systemctl --quiet daemon-reload
	sudo systemctl --quiet enable tmp.mount
	# tuned(8), see tuned-profiles(7)
	sudo tuned-adm profile latency-performance
	# unbound(8) DNS caching resolver
	sudo yum -qy install unbound
	sudo install -C -Z -o root -g root -m 0444 unbound.conf /etc/unbound/unbound.conf
	sudo touch /usr/local/etc/blocklist.conf
	echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf >/dev/null 2>&1 || true
	sudo chattr +i /etc/resolv.conf
	sudo systemctl --quiet enable --now unbound
	sudo install -C -Z -o root -g root -m 0544 dnsblock.sh /usr/local/sbin/dnsblock
	sudo install -C -Z -o root -g root -m 0444 dnsblock.service /etc/systemd/system/dnsblock.service
	sudo install -C -Z -o root -g root -m 0444 dnsblock.timer /etc/systemd/system/dnsblock.timer
	sudo systemctl --quiet daemon-reload
	sudo systemctl --quiet enable dnsblock.timer
	# sudo
	sudo install -C -Z -o root -g root -m 0444 sudoers /etc/sudoers

all: check install nvidia
