# Red Hat Enterprise Linux 8: Workstation
# Last tested: 23 August 2019

check:
	sudo sshd -t -f sshd_config
	sudo visudo --check --quiet -f sudoers
	sudo unbound-checkconf -f unbound.conf >/dev/null

nvidia:
	# note: dkms is in the EPEL repository
	sudo yum -qy install dkms elfutils-libelf-devel kernel-devel
	sudo systemctl enable --now dkms
	if [[ ! -f /usr/local/src/nvidia-430.40.run ]]; then sudo curl -sLo /usr/local/src/nvidia-430.40.run 'https://us.download.nvidia.com/XFree86/Linux-x86_64/430.40/NVIDIA-Linux-x86_64-430.40.run'; fi
	if [[ ! -d /var/lib/dkms/nvidia/430.40 ]]; then sudo sh /usr/local/src/nvidia-430.40.run --accept-license --no-questions --dkms --silent; fi

install:
	## remove and disable unnecessary things
	sudo yum -qy remove PackageKit-command-not-found baobab cheese eog evince evolution gedit gnome-boxes gnome-calculator gnome-font-viewer gnome-logs pidgin rhythmbox setroubleshoot subscription-manager-cockpit totem yelp
	sudo systemctl --quiet disable --now atd
	sudo systemctl --quiet disable --now avahi-daemon.service
	sudo systemctl --quiet disable --now avahi-daemon.socket
	sudo systemctl --quiet disable --now bolt
	sudo systemctl --quiet disable --now crond
	sudo systemctl --quiet disable --now cups.service
	sudo systemctl --quiet disable --now cups.socket
	sudo systemctl --quiet disable --now cups.path
	sudo systemctl --quiet disable --now ModemManager
	sudo systemctl --quiet disable --now rpcbind
	sudo systemctl --quiet disable --now rpcbind.socket
	sudo systemctl --quiet mask rpcbind
	sudo systemctl --quiet mask rpcbind.socket
	sudo touch /etc/cron.allow
	# only allow SSH by default
	sudo firewall-cmd --quiet --set-default-zone=dmz
	sudo firewall-cmd --quiet --lockdown-on
	## enable EPEL
	if [[ ! -f /etc/yum.repos.d/epel.repo ]]; then sudo yum -qy install epel-release 2>/dev/null || sudo yum -qy install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm; fi
	## install useful utilities
	sudo yum -qy install podman-docker qemu-img tmux
	#add once EPEL8 exists: lynx ncdu
	#     .. ncdu, rhbz#1741372: https://bugzilla.redhat.com/show_bug.cgi?id=1741372
	# install GNOME extensions and Tweaks
	sudo yum -qy install gnome-shell-extension-dash-to-dock gnome-shell-extension-native-window-placement gnome-shell-extension-no-hot-corner gnome-tweaks
	# enable flatpaks from Flathub.org
	sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	## copy confs
	# chrony time daemon
	sudo install -C -Z -o root -g root -m 0444 chrony.conf /etc/chrony.conf
	# firefox
	sudo install -C -Z -o root -g root -m 0444 firefox.json /usr/lib64/firefox/distribution/policies.json
	# NetworkManager
	sudo install -C -Z -o root -g root -m 0444 NetworkManager.conf /etc/NetworkManager/NetworkManager.conf
	# OpenSSH
	sudo install -C -Z -o root -g root -m 0444 sshd_config /etc/ssh/sshd_config
	# patchall script
	sudo install -C -Z -o root -g root -m 0544 patchall.sh /usr/local/sbin/patchall
	# polkit authorization policies
	sudo install -C -Z -o root -g root -m 0444 polkit_permit-usbs.rules /etc/polkit-1/rules.d/15-permit-usbs.rules
	sudo install -C -Z -o root -g root -m 0444 polkit_prohibit-shutdown.rules /etc/polkit-1/rules.d/55-prohibit-shutdown.rules
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
