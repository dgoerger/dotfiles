#!/bin/bash

##### CHANGEME #####
HEADLESS=no
HOST=gelos
INTEL_GPU=yes
NO_USB_PERIPHERALS=correct
RDP_CLIENT=no
RPMFUSION=no
TEXLIVE=no

########################
### Additional repos ###
########################
if [[ "$RPMFUSION" == "yes" ]]; then
  sudo dnf install -y http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-24.noarch.rpm
fi

########################
## Remove unnecessary ##
########################
# hardware - note this removes almost all wifi drivers
sudo dnf remove -y atmel-firmware b43* foomatic* fprintd glusterfs* gnome-boxes \
hpijs hplip-common hyperv* iscsi-initiator-utils iwl* libfprint \
libiscsi libvirt* memtest86+ NetworkManager-adsl NetworkManager-team \
openvpn pptp qemu* sane-backends spice* tigervnc* vpnc xen*

# dev tools and libs
sudo dnf remove -y abrt* devassistant* dos2unix fpaste java* libreport \
perl setroubleshoot* yum-metadata-parser

# help and accessibility
sudo dnf remove -y gnome-classic-session orca yelp*

# remove for security
sudo dnf remove -y evince-browser-plugin httpd*

# remove kerberos support in sasl
sudo dnf remove -y cyrus-sasl-gssapi

# misc unused graphical programs
sudo dnf remove -y baobab bijiben cheese empathy evolution ghostscript gnome-characters \
gnome-clocks gnome-contacts gnome-documents gnome-music gnome-system-monitor \
gnome-weather libreoffice* rhythmbox shotwell transmission-gtk

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
if [[ "$NO_USB_PERIPHERALS" == "correct" ]]; then
  sudo dnf install -y powertop
  sudo systemctl enable powertop
fi
## clean up PAM/fprintd so it doesn't spam the logs
# see: https://bugzilla.redhat.com/show_bug.cgi?id=1203671
sudo authconfig --disablefingerprint --update

########################
####### Software #######
########################
### security ###
sudo dnf install -y firewalld
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --lockdown-on
# TODO: chattr +i the firewall confs
## set stricter system crypto policy
# note NSS not until F25: https://bugzilla.redhat.com/show_bug.cgi?id=1157720
echo "FUTURE" | sudo tee /etc/crypto-policies/config
sudo update-crypto-policies
## respect Mozilla's CA trust revocation policy
# see: https://fedoraproject.org/wiki/CA-Certificates
sudo ca-legacy disable
## set DNS resolvers and local cache
# TODO: DNSCrypt for encrypted DNS lookups + DNSSEC
#       see: https://github.com/simonclausen/dnscrypt-autoinstall
sudo dnf install -y dnsmasq
sudo systemctl enable dnsmasq
echo -e "nameserver 127.0.0.1\nnameserver 8.8.8.8\nnameserver 4.4.4.4" | sudo tee /etc/resolv.conf >/dev/null
sudo chattr +i /etc/resolv.conf

### commandline apps ###
## all-around
sudo dnf install -y bsdtar colordiff git-core git-core-doc tmux tree vim-enhanced
## diagnosis
sudo dnf install -y htop lsof ncdu nmap
## productivity
sudo dnf install -y pandoc-static
if [[ "$TEXLIVE" == "yes" ]]; then
  sudo dnf install -y texlive-collection-xetex
fi
# spellcheck - why isn't en-CA packaged separately?
sudo dnf install -y hunspell-en

### system prefs
## set hostname
sudo hostnamectl set-hostname ${HOST}
sudo chattr +i /etc/hostname
## logging
sudo dnf install -y rsyslog
sudo systemctl enable rsyslog
sudo curl -L -o /etc/rsyslog.conf https://raw.githubusercontent.com/dgoerger/dotfiles/master/rsyslog.conf
sudo curl -L -o /etc/systemd/journald.conf https://github.com/dgoerger/dotfiles/raw/master/journald.conf
## ntpd
sudo dnf install -y ntp
sudo systemctl enable ntpd
## ssh
sudo curl -L -o /etc/ssh/sshd_config https://github.com/dgoerger/dotfiles/raw/master/sshd_config
sudo chmod 600 /etc/ssh/sshd_config
sudo curl -L -o /etc/ssh/ssh_config https://github.com/dgoerger/dotfiles/raw/master/ssh_config
sudo chmod 644 /etc/ssh/ssh_config
# use upstream ssh-agent for ed25519 support
sudo ln -sf /dev/null /etc/xdg/autostart/gnome-keyring-ssh.desktop
sudo curl -L -o /etc/systemd/user/ssh-agent.service https://github.com/dgoerger/dotfiles/raw/master/ssh-agent.service
sudo systemctl --global enable ssh-agent
## vim
echo -e '\n\n" default colours are unreadable\ncolorscheme elflord' | sudo tee --append /etc/vimrc


if [[ "$HEADLESS" == "yes" ]]; then
  ## firewall policy
  sudo firewall-cmd --set-default-zone=dmz
  ## sshd
  sudo systemctl enable sshd
  ## mail
  sudo dnf install -y cyrus-sasl-plain irssi mailcap mutt
  sudo curl -Lo /etc/mailcap https://github.com/dgoerger/dotfiles/raw/master/mailcap
  curl -Lo $HOME/.muttrc https://github.com/dgoerger/dotfiles/raw/master/muttrc
  ## news and podcasts
  sudo dnf install -y newsbeuter youtube-dl
  curl -Lo $HOME/.newsbeuter/config https://github.com/dgoerger/dotfiles/raw/master/newsbeuter_config
  curl -Lo $HOME/.newsbeuter/urls https://github.com/dgoerger/dotfiles/raw/master/newsbeuter_urls
  ## productivity
  sudo dnf install -y kpcli lynx ranger
else
  ## firewall policy
  sudo firewall-cmd --set-default-zone=drop
  ## productivity
  sudo dnf install -y firefox icecat keepassx
  if [[ "$RDP_CLIENT" == "yes" ]]; then
    sudo dnf install -y vinagre
  fi
  # Firefox - TODO move this to /etc/firefox/pref ?
  sudo mkdir -p /usr/lib64/firefox/browser/defaults/preferences
  sudo curl -L -o /usr/lib64/firefox/browser/defaults/preferences/user.js https://raw.githubusercontent.com/dgoerger/dotfiles/master/firefox_user.js
  ## multimedia
  sudo dnf install -y gstreamer1-plugins-bad-free
  if [[ "$RPMFUSION" == "yes" ]]; then
    sudo dnf install -y gstreamer1-libav
  fi
  sudo curl -o /usr/local/bin/photo_import https://github.com/dgoerger/dotfiles/raw/master/photo_import.sh
  sudo chmod +x /usr/local/bin/photo_import
  ## GNOME
  sudo dnf install -y gnome-shell-extension-alternate-tab
  sudo dnf install -y gedit-plugin-codecomment gedit-plugin-multiedit gedit-plugin-wordcompletion
fi

########################
#### Customizations ####
########################
## set some rc's
curl -L -o $HOME/.profile https://github.com/dgoerger/dotfiles/raw/master/profile
curl -L -o $HOME/.bashrc https://github.com/dgoerger/dotfiles/raw/master/bashrc
curl -L -o $HOME/.gitconfig https://github.com/dgoerger/dotfiles/raw/master/gitconfig
curl -L -o $HOME/.tmux.conf https://github.com/dgoerger/dotfiles/raw/master/tmux.conf
curl -L -o $HOME/.vimrc https://github.com/dgoerger/dotfiles/raw/master/vimrc
rm $HOME/.bash_profile
mkdir -p $HOME/.ssh
chmod 700 $HOME/.ssh
touch $HOME/.ssh/config
chmod 600 $HOME/.ssh/config
## why does ~/.pki exist
rm -rf $HOME/.pki
ln -s /dev/null $HOME/.pki

## GNOME
## TODO move system-level dconf prefs to /etc per https://wiki.gnome.org/Projects/dconf/SystemAdministrators
# privacy / security
dconf write /org/gnome/desktop/media-handling/autorun-never true
dconf write /org/gnome/desktop/privacy/report-technical-problems false
# shell
dconf write /org/gnome/desktop/datetime/automatic-timezone true
dconf write /org/gnome/desktop/interface/clock-show-date true
dconf write /org/gnome/shell/enabled-extensions "['alternate-tab@gnome-shell-extensions.gcampax.github.com']"
# mouse
dconf write /org/gnome/settings-daemon/peripherals/touchpad/natural-scroll true
dconf write /org/gnome/settings-daemon/peripherals/touchpad/tap-to-click true
# terminal
dconf write /org/gnome/terminal/legacy/default-show-menubar false
dconf write /org/gnome/terminal/legacy/keybindings/close-tab "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/move-tab-right "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/switch-to-tab-3 "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/close-window "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/switch-to-tab-4 "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/find "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/new-tab "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/new-window "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/switch-to-tab-5 "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/find-clear "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/next-tab "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/switch-to-tab-6 "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/find-next "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/prev-tab "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/switch-to-tab-7 "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/find-previous "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/switch-to-tab-1 "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/switch-to-tab-8 "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/help "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/switch-to-tab-10 "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/switch-to-tab-9 "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/move-tab-left "'disabled'"
dconf write /org/gnome/terminal/legacy/keybindings/switch-to-tab-2 "'disabled'"
dconf write /org/gnome/terminal/legacy/menu-accelerator-enabled false
dconf write /org/gnome/terminal/legacy/new-terminal-mode "'tab'"
# tracker / search indexing
dconf write /org/freedesktop/tracker/miner/files/index-recursive-directories "['&DESKTOP', '&DOCUMENTS']"
# nautilus
dconf write /org/gnome/nautilus/preferences/sort-directories-first true
# gedit - multiline with ctrl+e
dconf write /org/gnome/gedit/plugins/active-plugins "['codecomment', 'wordcompletion', 'multiedit', 'time', 'spell', 'modelines', 'filebrowser', 'docinfo']"
# eog
dconf write /org/gnome/eog/plugins/active-plugins "['fullscreen']"
# gtk - TODO move this to /etc/gtk-3.0 ?
mkdir -p $HOME/.config/gtk-3.0
echo -e "[Settings]\ngtk-application-prefer-dark-theme=1" > $HOME/.config/gtk-3.0/settings.ini
echo "gtk-enable-primary-paste=true" >> $HOME/.config/gtk-3.0/settings.ini
