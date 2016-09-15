#!/bin/bash

##### USAGE #####
if [[ -n "$1" ]]; then
  echo -e "\n\
  USAGE:\n\
  - edit, review all vars under CHANGEME section\n\
  - sh /path/to/postinstall.sh\n"
  exit 0
fi

##### CHANGEME #####
# is this a server sans gui
HEADLESS=no
# /etc/hostname ?
HOST=gelos
# is the gpu onboard Intel
INTEL_GPU=yes
# don't use powertop if you have usb peripherals
POWERTOP=yes
# do we need an RDP client
RDP_CLIENT=no
# enable rpmfusion.org free repo?
RPMFUSION=no
# pull in texlive?
TEXLIVE=no
# https://atom.io ?
ATOM_EDITOR=no
# use Google's official version of Chrome?
GOOGLE_CHROME=no


### bomb out if we're doing it wrong
if [[ "$(uname -m)" != "x86_64" ]]; then
  echo "ERROR! This script is only compatible with x86_64."
  exit 1
fi
if [[ "$(whoami)" == "root" ]]; then
  echo "DON'T RUN AS ROOT! DID YOU READ THE SCRIPT BEFORE EXECUTING??"
  exit 1
fi

########################
### Additional repos ###
########################
if [[ "$RPMFUSION" == "yes" ]]; then
  sudo dnf install -y http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-25.noarch.rpm
fi

########################
## Remove unnecessary ##
########################
# hardware - note this removes almost all wifi drivers
sudo dnf remove -y atmel-firmware b43* foomatic* fprintd glusterfs* gnome-boxes \
hpijs hplip-common hyperv* iscsi-initiator-utils iwl* libfprint \
libiscsi libvirt* memtest86+ NetworkManager-adsl NetworkManager-team \
open-vm-tools openvpn pptp qemu* sane-backends spice* tigervnc* vpnc xen*

# dev tools and libs
sudo dnf remove -y abrt* devassistant* fpaste java* libreport \
perl setroubleshoot* yum-metadata-parser

# help and accessibility
sudo dnf remove -y gnome-classic-session orca yelp*

# remove for security
sudo dnf remove -y evince-browser-plugin httpd*

# remove kerberos support in sasl
sudo dnf remove -y cyrus-sasl-gssapi

# misc unused graphical programs
sudo dnf remove -y baobab bijiben cheese empathy evolution file-roller \
ghostscript gnome-calculator gnome-characters gnome-clocks gnome-contacts \
gnome-documents gnome-music gnome-system-monitor gnome-weather libreoffice* \
rhythmbox shotwell transmission-*

# remove the fullscreen pinentry dialogue for gpg2
sudo dnf remove -y pinentry-gnome3

# clean up and patch
sudo dnf autoremove -y
sudo dnf upgrade -y

########################
### Hardware support ###
########################
## graphics
if [[ "$INTEL_GPU" == "yes" ]]; then
  sudo dnf install -y beignet
  if [[ "$RPMFUSION" == "yes" ]]; then
    sudo dnf install -y libva-intel-driver
  fi
fi
# OpenGL
sudo dnf install -y mesa-vdpau-drivers libva-vdpau-driver
## powertop
if [[ "$POWERTOP" == "yes" ]]; then
  sudo dnf install -y powertop
  sudo systemctl enable powertop
fi
## clean up PAM/fprintd so it doesn't spam the logs
# see: https://bugzilla.redhat.com/show_bug.cgi?id=1203671
sudo authconfig --disablefingerprint --update
## broken lenovo wifi driver
echo "blacklist ideapad_laptop" | sudo tee --append /etc/modprobe.d/blacklist.conf

########################
####### Software #######
########################
### security ###
sudo dnf install -y firewalld
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --lockdown-on
## set stricter system crypto policy
echo "FUTURE" | sudo tee /etc/crypto-policies/config
sudo update-crypto-policies
## respect Mozilla's CA trust revocation policy
# see: https://fedoraproject.org/wiki/CA-Certificates
sudo ca-legacy disable
## secure and cache dns
# dnscrypt primary lookup
sudo dnf install -y dnscrypt-proxy
sudo curl -Lo /etc/systemd/system/dnscrypt-proxy.service https://github.com/dgoerger/dotfiles/raw/master/dnscrypt-proxy.service
echo -e "LISTENER=127.0.0.1:40\nRESOLVER=dnscrypt.eu-dk" | sudo tee /etc/sysconfig/dnscrypt-proxy.conf
sudo userdel -r dnscrypt
sudo useradd -r -d /var/dnscrypt -m -s /sbin/nologin dnscrypt
sudo systemctl enable dnscrypt-proxy
sudo systemctl start dnscrypt-proxy
# set local cache of dnscrypt results
sudo dnf install -y dnsmasq
echo -e "no-resolv\nserver=127.0.0.1#40\nlisten-address=127.0.0.1" | sudo tee /etc/dnsmasq.d/dnscrypt.conf
sudo systemctl enable dnsmasq
sudo systemctl start dnsmasq
# configure backup dns - CAUTION - resiliency over security
sudo rm /etc/resolv.conf
echo -e "nameserver 127.0.0.1\nnameserver 8.8.8.8\nnameserver 208.67.222.222" | sudo tee /etc/resolv.conf >/dev/null
# prevent NetworkManager from overwriting resolv.conf through dhcp
sudo chattr +i /etc/resolv.conf
# malware/hosts block - uses dnsmasq instead of /etc/hosts
sudo curl -Lo /usr/local/bin/dnsblock_updater https://github.com/dgoerger/dotfiles/raw/master/dnsblock_updater
sudo chmod 0500 /usr/local/bin/dnsblock_updater
sudo mkdir -p /usr/local/src/hosts
sudo sh /usr/local/bin/dnsblock_updater
## automatic patching
echo "30 18 * * * /usr/bin/dnf upgrade -y" | sudo tee --append /var/spool/cron/root
echo "59 18 * * 5 /usr/local/bin/dnsblock_updater" | sudo tee --append /var/spool/cron/root

### commandline apps ###
## all-around
sudo dnf install -y bsdtar colordiff git-core git-core-doc tmux tree vim-enhanced
## diagnosis
sudo dnf install -y htop lsof ncdu nmap
## productivity
sudo dnf install -y pandoc-static unzip
if [[ "$TEXLIVE" == "yes" ]]; then
  sudo dnf install -y texlive-collection-xetex texlive-collection-luatex texlive-collection-latexrecommended texlive-collection-langenglish texlive-collection-mathextra
fi
# spellcheck - why isn't en-CA packaged separately?
sudo dnf install -y hunspell-en
## fonts
# emoji support
sudo dnf install -y gdouros-symbola-fonts

### system prefs
## set hostname
sudo hostnamectl set-hostname ${HOST}
sudo chattr +i /etc/hostname
## logging
sudo dnf install -y rsyslog
sudo systemctl enable rsyslog
sudo curl -Lo /etc/rsyslog.conf https://github.com/dgoerger/dotfiles/raw/master/rsyslog.conf
sudo curl -Lo /etc/systemd/journald.conf https://github.com/dgoerger/dotfiles/raw/master/journald.conf
## ntpd
sudo dnf install -y ntp
sudo systemctl enable ntpd
## ssh
sudo curl -Lo /etc/ssh/sshd_config https://github.com/dgoerger/dotfiles/raw/master/sshd_config
sudo chmod 600 /etc/ssh/sshd_config
# TODO append `Include /etc/ssh/ssh_config.d/*.conf` if rhbz#1225752 yields useful results
sudo curl -Lo /etc/ssh/ssh_config https://github.com/dgoerger/dotfiles/raw/master/ssh_config
sudo chmod 644 /etc/ssh/ssh_config
# use upstream ssh-agent for ed25519 support
sudo ln -sf /dev/null /etc/xdg/autostart/gnome-keyring-ssh.desktop
sudo curl -Lo /etc/systemd/user/ssh-agent.service https://github.com/dgoerger/dotfiles/raw/master/ssh-agent.service
sudo systemctl --global enable ssh-agent
## useful bash aliases
sudo curl -Lo /etc/profile.d/custom_aliases.sh https://github.com/dgoerger/dotfiles/raw/master/aliases
## vim
sudo curl -Lo /etc/vimrc https://github.com/dgoerger/dotfiles/raw/master/vimrc
## tmux
sudo curl -Lo /etc/tmux.conf https://github.com/dgoerger/dotfiles/raw/master/tmux.conf
## git
sudo curl -Lo /etc/gitconfig https://github.com/dgoerger/dotfiles/raw/master/gitconfig


if [[ "$HEADLESS" == "yes" ]]; then
  ## firewall policy
  sudo firewall-cmd --set-default-zone=dmz
  # clean up renegade cockpit.service reference, see rhbz#1171114
  sudo rm /usr/lib/firewalld/zones/FedoraServer.xml
  sudo chattr +i /etc/firewalld/firewalld.conf
  ## sshd
  sudo systemctl enable sshd
  ## disable KillUserProcesses until there's a solid way to not kill tmux
  sudo cp -p /etc/systemd/logind.conf{,.orig}
  sudo curl -Lo /etc/systemd/logind.conf https://github.com/dgoerger/dotfiles/raw/master/logind.conf
  ## mail
  sudo dnf install -y cyrus-sasl-plain mailcap mutt
  sudo curl -Lo /etc/mailcap https://github.com/dgoerger/dotfiles/raw/master/mailcap
  curl -Lo $HOME/.muttrc https://github.com/dgoerger/dotfiles/raw/master/muttrc
  ## news and podcasts
  sudo dnf install -y newsbeuter youtube-dl
  mkdir -p $HOME/.newsbeuter
  curl -Lo $HOME/.newsbeuter/config https://github.com/dgoerger/dotfiles/raw/master/newsbeuter_config
  curl -Lo $HOME/.newsbeuter/urls https://github.com/dgoerger/dotfiles/raw/master/newsbeuter_urls
  ## productivity
  sudo dnf install -y kpcli lynx ranger
else
  ## firewall policy
  sudo firewall-cmd --set-default-zone=drop
  sudo chattr +i /etc/firewalld/firewalld.conf
  ## productivity
  sudo dnf install -y firefox fuse-sshfs icecat keepassx
  if [[ "$RDP_CLIENT" == "yes" ]]; then
    sudo dnf install -y vinagre
  fi
  # Firefox - TODO move this to /etc/firefox/pref ?
  sudo mkdir -p /usr/lib64/firefox/browser/defaults/preferences
  sudo curl -Lo /usr/lib64/firefox/browser/defaults/preferences/user.js https://github.com/dgoerger/dotfiles/raw/master/firefox_user.js
  ## multimedia
  sudo dnf install -y gstreamer1-plugins-bad-free
  if [[ "$RPMFUSION" == "yes" ]]; then
    sudo dnf install -y gstreamer1-libav
  fi
  if [[ "$GOOGLE_CHROME" == "yes" ]]; then
    sudo dnf install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
  fi
  if [[ "$TEXLIVE" == "yes" ]]; then
    sudo dnf install -y latexila
  fi
  if [[ "$ATOM_EDITOR" == "yes" ]]; then
    sudo dnf copr enable mosquito/atom -y
    sudo dnf install -y atom
  fi
  sudo curl -Lo /usr/local/bin/photo_import https://github.com/dgoerger/dotfiles/raw/master/photo_import.sh
  sudo chmod +x /usr/local/bin/photo_import
  ## GNOME
  sudo dnf install -y gnome-shell-extension-alternate-tab
  sudo dnf install -y gedit-plugin-codecomment gedit-plugin-multiedit gedit-plugin-wordcompletion
  # dconf gdm login screen
  sudo mkdir -p /etc/dconf/db/gdm.d
  sudo mkdir -p /etc/dconf/profile
  echo -e "[org/gnome/desktop/interface]\nclock-show-date=true" | sudo tee /etc/dconf/db/gdm.d/custom-gdm-settings
  sudo curl -Lo /etc/dconf/db/gdm.d/custom-gdm-settings https://github.com/dgoerger/dotfiles/raw/master/dconf_gdm
  echo -e "user-db:user\nsystem-db:gdm" | sudo tee /etc/dconf/profile/gdm
  # dconf default user profiles
  sudo mkdir -p /etc/dconf/db/site.d
  sudo curl -Lo /etc/dconf/db/site.d/custom-user-defaults https://github.com/dgoerger/dotfiles/raw/master/dconf_user
  echo -e "user-db:user\nsystem-db:site" | sudo tee /etc/dconf/profile/user
  sudo dconf update
  # global dark theme and middle paste
  sudo mkdir -p /etc/gtk-3.0
  echo -e "[Settings]\ngtk-application-prefer-dark-theme=1\ngtk-enable-primary-paste=true" | sudo tee /etc/gtk-3.0/settings.ini
fi

########################
#### Customizations ####
########################
## set some rc's
curl -Lo $HOME/.profile https://github.com/dgoerger/dotfiles/raw/master/profile
curl -Lo $HOME/.bashrc https://github.com/dgoerger/dotfiles/raw/master/bashrc
rm $HOME/.bash_profile
# set some ~/.ssh perms so we don't have to deal with it later
mkdir -p $HOME/.ssh
chmod 700 $HOME/.ssh
touch $HOME/.ssh/authorized_keys
chmod 600 $HOME/.ssh/authorized_keys
touch $HOME/.ssh/config
chmod 600 $HOME/.ssh/config
## why does ~/.pki exist
rm -rf $HOME/.pki
ln -s /dev/null $HOME/.pki
