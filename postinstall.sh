#!/bin/bash

########################
### Additional repos ###
########################
#dnf install -y http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-23.noarch.rpm

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
sudo dnf remove baobab bijiben cheese empathy evolution ghostscript gnome-characters \
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
sudo dnf install -y bsdtar git-core git-core-doc lynx ntp ranger tmux tree vim-enhanced
## diagnosis
sudo dnf install -y htop lsof ncdu
## productivity
sudo dnf install -y pandoc-static transmission-cli
## mail
#sudo dnf install -y cyrus-sasl-plain mailcap mutt
#sudo curl -Lo /etc/mailcap https://github.com/dgoerger/dotfiles/raw/master/mailcap
#curl -Lo $HOME/.muttrc https://github.com/dgoerger/dotfiles/raw/master/muttrc
## multimedia
sudo curl -o /usr/local/bin/photo_import https://github.com/dgoerger/dotfiles/raw/master/photo_import.sh
sudo chmod +x /usr/local/bin/photo_import
## security
sudo dnf install -y firewalld nmap
sudo systemctl enable firewalld
sudo firewall-cmd --set-default-zone=drop
sudo firewall-cmd --lockdown-on
## set stricter system crypto policy
# note NSS not until F25: https://bugzilla.redhat.com/show_bug.cgi?id=1157720
echo "FUTURE" | sudo tee /etc/crypto-policies/config
sudo update-crypto-policies
## respect Mozilla's CA trust revocation policy
# see: https://fedoraproject.org/wiki/CA-Certificates
sudo ca-legacy disable
### TODO: refactor dnscrypt section, remove dependency on outside source
### set DNSCrypt for encrypted DNS lookups + DNSSEC
## note this step is interactive
## might need modification at some point: https://fedoraproject.org/wiki/Changes/Default_Local_DNS_Resolver
## important: /etc/resolv.conf is left with attr +i (immutable bit)
#sudo mkdir -p /usr/local/src/dnscrypt
#sudo curl -L -o /usr/local/src/dnscrypt/redhat.sh https://raw.githubusercontent.com/simonclausen/dnscrypt-autoinstall/master/dnscrypt-autoinstall-redhat.sh
#sudo chmod +x /usr/local/src/dnscrypt/redhat.sh
## yum is deprecated
#sudo sed -i 's/yum/dnf/g' /usr/local/src/dnscrypt/redhat.sh
## for some reason this one line doesn't have sudo, ergo it fails
#sudo sed -i 's/dnf\ install\ -y\ libsodium-devel/sudo\ dnf\ install\ -y\ libsodium-devel/' /usr/local/src/dnscrypt/redhat.sh
## also it assumes we have gpg---not necessarily true
#sudo dnf install -y gpg
#sh /usr/local/src/dnscrypt/redhat.sh


### system libraries ###
# multimedia
sudo dnf install -y gstreamer1-plugins-bad-free
#dnf install -y gstreamer1-libav #requires enabling rpmfusion-free
# LaTeX
sudo dnf install -y texlive-collection-xetex
# spellcheck - why isn't en-CA packaged separately?
sudo dnf install -y hunspell-en

### graphical applications ###
# productivity
sudo dnf install -y keepassx
#sudo dnf install -y vinagre
sudo dnf install -y firefox icecat
sudo dnf install -y xsel
sudo dnf install -y youtube-dl

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
sudo curl -L -o /etc/systemd/user/ssh-agent.service https://github.com/dgoerger/dotfiles/raw/master/ssh-agent.service
curl -L -o $HOME/.profile https://github.com/dgoerger/dotfiles/raw/master/profile
rm $HOME/.bash_profile
# uncomment on terminal workstations where ssh-agent should start with systemd login event
# -> and not on headless servers where it starts with ssh ForwardAgent event
echo -e '\nexport SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"' >> $HOME/.profile
sudo systemctl --global enable ssh-agent
## vim default colorscheme is almost unreadable
echo -e '\n" default colours are unreadable\ncolorscheme elflord' | sudo tee --append /etc/vimrc
## not sure why ntpd isn't enabled by default
sudo systemctl enable ntpd
## set ssh config
mkdir -p $HOME/.ssh
curl -L -o $HOME/.ssh/config https://github.com/dgoerger/dotfiles/raw/master/ssh_config
chmod 700 $HOME/.ssh
chmod 600 $HOME/.ssh/config
## set some rc's
curl -L -o $HOME/.bashrc https://github.com/dgoerger/dotfiles/raw/master/bashrc
curl -L -o $HOME/.gitconfig https://github.com/dgoerger/dotfiles/raw/master/gitconfig
curl -L -o $HOME/.tmux.conf https://github.com/dgoerger/dotfiles/raw/master/tmux.conf
curl -L -o $HOME/.vimrc https://github.com/dgoerger/dotfiles/raw/master/vimrc
curl -L -o $HOME/.lynx_bookmarks https://github.com/dgoerger/dotfiles/raw/master/lynx_bookmarks
## why does ~/.pki exist
rm -rf $HOME/.pki
ln -s /dev/null $HOME/.pki
## transmission rc
mkdir -p $HOME/.config/transmission
curl -L -o $HOME/.config/transmission/settings.json https://github.com/dgoerger/dotfiles/raw/master/transmission-settings.json
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
sudo dnf install -y gedit-plugin-codecomment gedit-plugin-multiedit gedit-plugin-wordcompletion
dconf write /org/gnome/gedit/plugins/active-plugins "['codecomment', 'wordcompletion', 'multiedit', 'time', 'spell', 'modelines', 'filebrowser', 'docinfo']"
# eog
dconf write /org/gnome/eog/plugins/active-plugins "['fullscreen']"
# gtk - TODO move this to /etc/gtk-3.0 ?
mkdir -p $HOME/.config/gtk-3.0
echo -e "[Settings]\ngtk-application-prefer-dark-theme=1" > $HOME/.config/gtk-3.0/settings.ini
echo "gtk-enable-primary-paste=true" >> $HOME/.config/gtk-3.0/settings.ini

### Firefox ###
# TODO move this to /etc/firefox/pref ?
sudo mkdir -p /usr/lib64/firefox/browser/defaults/preferences
sudo curl -L -o /usr/lib64/firefox/browser/defaults/preferences/user.js https://raw.githubusercontent.com/dgoerger/dotfiles/master/firefox_user.js
