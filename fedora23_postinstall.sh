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

########################
####### Software #######
########################
### commandline apps ###
# all-around
sudo dnf install -y git git-cal tig tmux tmux-powerline vim-enhanced
## compile links from source: http://links.twibright.com/download.php
# fetch source
#cd /tmp
#curl -LO http://links.twibright.com/download/links-2.12.tar.gz
#tar -xf links-2.12.tar.gz
#cd /tmp/links-2.12
# install build deps
#sudo dnf install -y gcc openssl-devel
# compile!
#./configure -with-ssl
#make
#sudo make install
# clean up (static linking)
#sudo dnf remove -y binutils cpp gcc glibc-devel glibc-headers isl \
#kernel-headers keyutils-libs-devel krb5-devel libcom_err-devel libmpc \
#libselinux-devel libsepol-devel libverto-devel openssl-devel pcre-devel \
#zlib-devel
## compile cmus from source: https://cmus.github.io (foss libs only)
# fetch source
#cd /tmp
#curl -LO https://github.com/cmus/cmus/archive/v2.7.1.tar.gz
#tar -xf v2.7.1.tar.gz
#cd cmus-2.7.1
# install build deps
#sudo dnf install -y gcc ncurses-devel libcddb-devel libcdio-paranoia-devel \
#flac-devel libvorbis-devel opusfile-devel pulseaudio-libs-devel libao-devel \
#libdiscid-devel
# compile!
#./configure CONFIG_CDDB=y CONFIG_CDIO=y CONFIG_DISCID=y CONFIG_FLAC=y \
#CONFIG_MAD=n CONFIG_MODPLUG=n CONFIG_MPC=n CONFIG_VORBIS=y CONFIG_OPUS=y \
#CONFIG_WAVPACK=n CONFIG_MP4=n CONFIG_AAC=n CONFIG_FFMPEG=n CONFIG_VTX=n \
#CONFIG_CUE=n CONFIG_ROAR=n CONFIG_PULSE=y CONFIG_ALSA=n CONFIG_JACK=n \
#CONFIG_SAMPLERATE=n CONFIG_AO=y CONFIG_ARTS=n CONFIG_OSS=n CONFIG_SNDIO=n \
#CONFIG_SUN=n CONFIG_WAVEOUT=n
#make
#sudo make install
# clean up
#sudo dnf remove -y binutils cpp gcc glibc-devel glibc-headers isl \
#kernel-headers libmpc ncurses-devel libcddb libcddb-devel \
#libcdio-paranoia-devel libcdio-devel autoconf automake flac-devel \
#libogg-devel m4 perl-Thread-Queue libvorbis-devel keyutils-libs-devel \
#krb5-devel libcom_err-devel libselinux-devel libsepol-devel libverto-devel \
#openssl-devel opus-devel opusfile opusfile-devel pcre-devel zlib-devel \
#pulseaudio-libs-devel glib2-devel libao libao-devel libdiscid libdiscid-devel \
#flac flac-devel
# make sure we didn't uninstall too much (linked libraries)
#sudo dnf install -y flac libao libcddb libcdio-paranoia libdiscid opusfile
## diagnosis
sudo dnf install -y htop lsof ncdu traceroute
## productivity
sudo dnf install -y pandoc-static transmission-cli
# vim-like console spreadsheet: https://github.com/andmarti1424/sc-im
# presentations via rst:
sudo dnf install -y hovercraft
## security
sudo dnf install -y firewalld nmap ykpers
sudo systemctl enable firewalld
sudo firewall-cmd --set-default-zone=drop
sudo firewall-cmd --lockdown-on
## set stricter system crypto policy
# note NSS doesn't comply: https://bugzilla.mozilla.org/show_bug.cgi?id=1009429
#                          https://bugzilla.redhat.com/show_bug.cgi?id=1157720
echo "FUTURE" | sudo tee /etc/crypto-policies/config
sudo update-crypto-policies
## set DNSCrypt for encrypted DNS lookups + DNSSEC
# note this step is interactive
# might need modification in f24: https://fedoraproject.org/wiki/Changes/Default_Local_DNS_Resolver
cd /tmp
sudo curl -LO https://raw.githubusercontent.com/simonclausen/dnscrypt-autoinstall/master/dnscrypt-autoinstall-redhat.sh
sudo chmod +x dnscrypt-autoinstall-redhat.sh
# yum is deprecated
sudo sed -i 's/yum/dnf/g' dnscrypt-autoinstall-redhat.sh
# for some reason this one line doesn't have sudo, ergo it fails
sudo sed -i 's/dnf\ install\ -y\ libsodium-devel/sudo\ dnf\ install\ -y\ libsodium-devel/'
# also it assumes we have gpg---not necessarily true
sudo dnf install -y gpg
./dnscrypt-autoinstall-redhat.sh
# TODO: manually splice in DNS for uni resources, noting /etc/resolv.conf has the immutable bit (chattr +i)

### system libraries ###
# fonts
#-
# multimedia
sudo dnf install -y gstreamer1-plugins-bad-free
#sudo dnf install -y http://download1.rpmfusion.org/free/fedora/updates/testing/23/x86_64/gstreamer1-libav-1.6.1-2.f23.x86_64.rpm
#dnf install -y gstreamer1-libav #requires enabling rpmfusion-free
# productivity
sudo dnf install -y texlive-collection-xetex
# spellcheck
sudo dnf install -y hunspell-en
# docker
sudo dnf install -y docker-vim
#sudo dnf install -y docker
#sudo systemctl enable docker
#sudo gpasswd -a ${USER} docker

### graphical applications ###
# multimedia
sudo dnf install -y shotwell
# awful workaround for gnome#739396
sudo chmod 444 /usr/libexec/shotwell/shotwell-video-thumbnailer
# productivity
sudo dnf install -y gnumeric
#sudo dnf install -y keepassx #keepassx 2.0 brings kdbx support
#sudo dnf install -y vinagre
# Internet - epiphany file is incognito-only mode
sudo dnf install -y epiphany firefox
curl -L -o $HOME/.local/share/applications/epiphany.desktop https://raw.githubusercontent.com/dgoerger/dotfiles/master/epiphany.desktop

### GNOME tweaks ###
# GNOME Shell
sudo dnf install -y gnome-shell-extension-alternate-tab

########################
#### Customizations ####
########################
## set hostname
sudo hostnamectl set-hostname gelos
#sudo hostnamectl set-hostname erebus
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
curl -L -o $HOME/.bash_profile https://github.com/dgoerger/dotfiles/raw/master/bash_profile
curl -L -o $HOME/.bashrc https://github.com/dgoerger/dotfiles/raw/master/bashrc
curl -L -o $HOME/.gitconfig https://github.com/dgoerger/dotfiles/raw/master/gitconfig
curl -L -o $HOME/.tmux.conf https://github.com/dgoerger/dotfiles/raw/master/tmux.conf
curl -L -o $HOME/.vimrc https://github.com/dgoerger/dotfiles/raw/master/vimrc
# custom xdg dirs
#mkdir -p $HOME/.config
#curl -L -o $HOME/.config/user-dirs.dirs https://github.com/dgoerger/dotfiles/raw/master/user-dirs.dirs
## GNOME
dconf write /org/gnome/desktop/privacy/report-technical-problems false
dconf write /org/gnome/shell/enabled-extensions "['alternate-tab@gnome-shell-extensions.gcampax.github.com']"
dconf write /org/gnome/desktop/interface/clock-show-date true
dconf write /org/gnome/terminal/legacy/default-show-menubar false
dconf write /org/gnome/settings-daemon/peripherals/touchpad/natural-scroll true
dconf write /org/gnome/settings-daemon/peripherals/touchpad/tap-to-click true
dconf write /org/freedesktop/tracker/miner/files/index-recursive-directories "['&DESKTOP', '&DOCUMENTS', '&VIDEOS']"
dconf write /org/gnome/desktop/media-handling/autorun-never true
dconf write /org/gnome/desktop/datetime/automatic-timezone true
dconf write /org/gnome/nautilus/preferences/sort-directories-first true
mkdir -p $HOME/.config/gtk-3.0
echo -e "[Settings]\ngtk-application-prefer-dark-theme=1" > $HOME/.config/gtk-3.0/settings.ini
## Shotwell
dconf write /org/yorba/shotwell/preferences/files/commit-metadata true
dconf write /org/yorba/shotwell/preferences/files/use-lowercase-filenames true
dconf write /org/yorba/shotwell/preferences/ui/use-24-hour-time true
dconf write /org/yorba/shotwell/preferences/ui/hide-photos-already-imported true

### Firefox ###
sudo mkdir -p /usr/lib64/firefox/browser/defaults/preferences
sudo curl -L -o /usr/lib64/firefox/browser/defaults/preferences/user.js https://raw.githubusercontent.com/dgoerger/dotfiles/master/firefox_user.js

### Chrome ###
#sudo dnf install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
