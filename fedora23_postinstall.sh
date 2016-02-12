#!/bin/bash

########################
### Additional repos ###
########################
#dnf install -y http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-23.noarch.rpm

########################
## Remove unnecessary ##
########################
sudo dnf remove abrt* b43* baobab bijiben cheese devassistant* dos2unix \
empathy evince-browser-plugin evolution foomatic* fpaste fprintd \
glusterfs* gnome-boxes gnome-characters gnome-classic-session gnome-clocks \
gnome-contacts gnome-documents gnome-music gnome-system-monitor gnome-weather \
hpijs hplip-common httpd* hyperv* iscsi-initiator-utils iwl* java* libfprint \
libiscsi libreoffice* libreport libvirt* memtest86+ NetworkManager-adsl \
NetworkManager-team openvpn orca perl pptp qemu* rhythmbox \
sane-backends setroubleshoot* shotwell spice* tigervnc* transmission-gtk vpnc \
xen* yelp* yum-metadata-parser
sudo dnf autoremove -y
sudo dnf upgrade -y

########################
### Hardware support ###
########################
## graphics
# OpenCL - Intel
sudo dnf install -y beignet
# OpenGL
sudo dnf install -y mesa-vdpau-drivers libva-vdpau-driver
## powertop
sudo dnf install -y powertop
sudo systemctl enable powertop
## clean up PAM/fprintd so it doesn't spam the logs
# see: https://bugzilla.redhat.com/show_bug.cgi?id=1203671
sudo authconfig --disablefingerprint --update

########################
####### Software #######
########################
### commandline apps ###
# all-around
sudo dnf install -y bsdtar git git-cal ranger tmux vim-enhanced
## diagnosis
sudo dnf install -y htop lsof ncdu traceroute
## productivity
sudo dnf install -y pandoc-static transmission-cli
## security
sudo dnf install -y firewalld nmap
sudo systemctl enable firewalld
sudo firewall-cmd --set-default-zone=drop
sudo firewall-cmd --lockdown-on
## set stricter system crypto policy
# note NSS not until F25: https://bugzilla.mozilla.org/show_bug.cgi?id=1009429
#                         https://bugzilla.redhat.com/show_bug.cgi?id=1157720
echo "FUTURE" | sudo tee /etc/crypto-policies/config
sudo update-crypto-policies
## respect Mozilla's CA trust revocation policy
# see: https://fedoraproject.org/wiki/CA-Certificates
sudo ca-legacy disable
## set DNSCrypt for encrypted DNS lookups + DNSSEC
# note this step is interactive
# might need modification in f24: https://fedoraproject.org/wiki/Changes/Default_Local_DNS_Resolver
# important: /etc/resolv.conf is left with attr +i (immutable bit)
cd /tmp
sudo curl -LO https://raw.githubusercontent.com/simonclausen/dnscrypt-autoinstall/master/dnscrypt-autoinstall-redhat.sh
sudo chmod +x /tmp/dnscrypt-autoinstall-redhat.sh
# yum is deprecated
sudo sed -i 's/yum/dnf/g' /tmp/dnscrypt-autoinstall-redhat.sh
# for some reason this one line doesn't have sudo, ergo it fails
sudo sed -i 's/dnf\ install\ -y\ libsodium-devel/sudo\ dnf\ install\ -y\ libsodium-devel/' /tmp/dnscrypt-autoinstall-redhat.sh
# also it assumes we have gpg---not necessarily true
sudo dnf install -y gpg
./tmp/dnscrypt-autoinstall-redhat.sh

### system libraries ###
# multimedia
sudo dnf install -y gstreamer1-plugins-bad-free
#dnf install -y gstreamer1-libav #requires enabling rpmfusion-free
# productivity
sudo dnf install -y texlive-collection-xetex
# spellcheck
sudo dnf install -y hunspell-en

### graphical applications ###
# multimedia
sudo dnf install -y gthumb
# productivity
sudo dnf install -y keepassx
sudo dnf install -y vinagre
sudo dnf install -y firefox icecat

### GNOME tweaks ###
# GNOME Shell
sudo dnf install -y gnome-shell-extension-alternate-tab

########################
#### Customizations ####
########################
## set hostname
sudo hostnamectl set-hostname gelos
## journald
sudo curl -L -o /etc/systemd/journald.conf https://github.com/dgoerger/dotfiles/raw/master/journald.conf
## use upstream ssh-agent for ed25519 support
sudo ln -sf /dev/null /etc/xdg/autostart/gnome-keyring-ssh.desktop
mkdir -p $HOME/.config/systemd/user
curl -L -o $HOME/.config/systemd/user/ssh-agent.service https://github.com/dgoerger/dotfiles/raw/master/ssh-agent.service
systemctl --user enable ssh-agent
## set ssh config
mkdir -p $HOME/.ssh
curl -L -o $HOME/.ssh/config https://github.com/dgoerger/dotfiles/raw/master/ssh_config
chmod 700 $HOME/.ssh
chmod 600 $HOME/.ssh/config
## set some rc's
curl -L -o $HOME/.profile https://github.com/dgoerger/dotfiles/raw/master/profile
rm $HOME/.bash_profile
curl -L -o $HOME/.bashrc https://github.com/dgoerger/dotfiles/raw/master/bashrc
curl -L -o $HOME/.gitconfig https://github.com/dgoerger/dotfiles/raw/master/gitconfig
curl -L -o $HOME/.tmux.conf https://github.com/dgoerger/dotfiles/raw/master/tmux.conf
curl -L -o $HOME/.vimrc https://github.com/dgoerger/dotfiles/raw/master/vimrc
## transmission rc
mkdir -p $HOME/.config/transmission
curl -L -o $HOME/.config/transmission/settings.json https://github.com/dgoerger/dotfiles/raw/master/transmission-settings.json
# custom xdg dirs
#mkdir -p $HOME/.config
#curl -L -o $HOME/.config/user-dirs.dirs https://github.com/dgoerger/dotfiles/raw/master/user-dirs.dirs
## GNOME
dconf write /org/gnome/desktop/privacy/report-technical-problems false
dconf write /org/gnome/shell/enabled-extensions "['alternate-tab@gnome-shell-extensions.gcampax.github.com']"
dconf write /org/gnome/desktop/interface/clock-show-date true
dconf write /org/gnome/terminal/legacy/default-show-menubar false
dconf write /org/gnome/terminal/legacy/menu-accelerator-enabled false
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
dconf write /org/gnome/terminal/legacy/new-terminal-mode "'tab'"
dconf write /org/gnome/settings-daemon/peripherals/touchpad/natural-scroll true
dconf write /org/gnome/settings-daemon/peripherals/touchpad/tap-to-click true
dconf write /org/freedesktop/tracker/miner/files/index-recursive-directories "['&DESKTOP', '&DOCUMENTS']"
dconf write /org/gnome/desktop/media-handling/autorun-never true
dconf write /org/gnome/desktop/datetime/automatic-timezone true
dconf write /org/gnome/nautilus/preferences/sort-directories-first true
mkdir -p $HOME/.config/gtk-3.0
echo -e "[Settings]\ngtk-application-prefer-dark-theme=1" > $HOME/.config/gtk-3.0/settings.ini
echo "gtk-enable-primary-paste=true" >> $HOME/.config/gtk-3.0/settings.ini

### Firefox ###
sudo mkdir -p /usr/lib64/firefox/browser/defaults/preferences
sudo curl -L -o /usr/lib64/firefox/browser/defaults/preferences/user.js https://raw.githubusercontent.com/dgoerger/dotfiles/master/firefox_user.js

### Chrome ###
#sudo dnf install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
