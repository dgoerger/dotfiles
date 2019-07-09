# Red Hat Enterprise Linux 8: Workstation
# Last tested: 18 June 2019

check:
	sudo sshd -t -f sshd_config
	sudo visudo --check --quiet -f sudoers
	sudo unbound-checkconf -f unbound.conf >/dev/null

nvidia:
	# NB: dkms is in the EPEL repository, or needs to be compiled from source
	#     .. interim cache: https://sdf.org/~dgoerger/linux/el8/RPMS/noarch/dkms-2.7.1-1.el8.noarch.rpm
	sudo yum -qy install dkms elfutils-libelf-devel kernel-devel
	if [[ ! -f /usr/local/src/nvidia-430.34.run ]]; then sudo curl -sLo /usr/local/src/nvidia-430.34.run 'https://us.download.nvidia.com/XFree86/Linux-x86_64/430.34/NVIDIA-Linux-x86_64-430.34.run'; fi
	if [[ ! -d /var/lib/dkms/nvidia/430.34 ]]; then sudo sh /usr/local/src/nvidia-430.34.run --accept-license --no-questions --dkms --silent; fi

install:
	## remove and disable unnecessary things
	sudo yum -qy remove PackageKit-command-not-found baobab cheese eog evolution gedit gnome-boxes gnome-calculator gnome-font-viewer gnome-logs pidgin rhythmbox setroubleshoot totem yelp
	sudo systemctl --quiet disable --now avahi-daemon.service
	sudo systemctl --quiet disable --now avahi-daemon.socket
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
	## install useful utilities
	sudo yum -qy install tmux
	#add once EPEL8 exists: lynx ncdu
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
	# polkit authorization policies
	sudo install -C -Z -o root -g root -m 0444 polkit_permit-usbs.rules /etc/polkit-1/rules.d/15-permit-usbs.rules
	sudo install -C -Z -o root -g root -m 0444 polkit_prohibit-shutdown.rules /etc/polkit-1/rules.d/55-prohibit-shutdown.rules
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
