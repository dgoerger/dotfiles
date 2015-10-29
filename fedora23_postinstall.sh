#!/bin/bash

########################
### Additional repos ###
########################
#dnf install -y http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-22.noarch.rpm

########################
## Remove unnecessary ##
########################
sudo dnf remove -y abrt* b43* baobab bijiben cheese devassistant* dos2unix dnf-yum empathy evince-browser-plugin evolution foomatic* fpaste fprintd glusterfs* gnome-boxes gnome-characters gnome-classic-session gnome-clocks gnome-contacts gnome-documents gnome-music gnome-system-monitor gnome-weather hpijs hplip-common httpd* hyperv* iscsi-initiator-utils iwl* java* libfprint libiscsi libreoffice* libreport libvirt* memtest86+ NetworkManager-adsl NetworkManager-team openvpn orca perl pptp python qemu* rhythmbox sane-backends setroubleshoot* shotwell spice* tigervnc* transmission-gtk vpnc xen* yelp* yum-metadata-parser
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

########################
####### Software #######
########################
### commandline apps ###
# all-around
sudo dnf install -y git git-cal git-extras sl tig tmux tmux-powerline traceroute vim-enhanced vim-fugitive
## compile links from source: http://links.twibright.com/download.php
# configure with openssl, ipv6, zlib, utf8 (no x11/graphics)---i.e. default
sudo dnf install -y gcc openssl-devel
cd /tmp/
curl -LO http://links.twibright.com/download/links-2.12.tar.gz
tar -xf links-2.12.tar.gz
cd /tmp/links-2.12
./configure -with-ssl
make
sudo make install
cd ~
sudo dnf remove -y binutils cpp gcc glibc-devel glibc-headers isl kernel-headers keyutils-libs-devel krb5-devel libcom_err-devel libmpc libselinux-devel libsepol-devel libverto-devel openssl-devel pcre-devel zlib-devel
## compile cmus from source: https://cmus.github.io (foss libs only)
# ./configure CONFIG_CDDB=y CONFIG_CDIO=y CONFIG_DISCID=y CONFIG_FLAC=y \
# CONFIG_MAD=n CONFIG_MODPLUG=n CONFIG_MPC=n CONFIG_VORBIS=y CONFIG_OPUS=y \
# CONFIG_WAVPACK=n CONFIG_MP4=n CONFIG_AAC=n CONFIG_FFMPEG=n CONFIG_VTX=n \
# CONFIG_CUE=n CONFIG_ROAR=n CONFIG_PULSE=y CONFIG_ALSA=n CONFIG_JACK=n \
# CONFIG_SAMPLERATE=n CONFIG_AO=y CONFIG_ARTS=n CONFIG_OSS=n CONFIG_SNDIO=n \
# CONFIG_SUN=n CONFIG_WAVEOUT=n
# monitoring
sudo dnf install -y htop lsof ncdu
# productivity
sudo dnf install -y pandoc-static transmission-cli
# security
sudo dnf install -y firewalld nmap ykpers
sudo systemctl enable firewalld
sudo firewall-cmd --set-default-zone=drop
# set stricter system crypto policy
# note NSS doesn't comply: https://bugzilla.mozilla.org/show_bug.cgi?id=1009429
#                          https://bugzilla.redhat.com/show_bug.cgi?id=1157720
echo "FUTURE" | sudo tee /etc/crypto-policies/config
sudo update-crypto-policies

### system libraries ###
# fonts
#-
# multimedia
sudo dnf install -y gstreamer1-plugins-bad-free gstreamer1-vaapi
#dnf install -y gstreamer1-libav # requires enabling rpmfusion-free
# productivity
sudo dnf install -y texlive-collection-xetex
# spellcheck
sudo dnf install -y hunspell-en hunspell-es hunspell-de hunspell-fr
# docker
sudo dnf install -y docker docker-vim
sudo systemctl enable docker
sudo gpasswd -a ${USER} docker

### graphical applications ###
# multimedia
sudo dnf install -y shotwell
# awful workaround for gnome#739396
sudo chmod 444 /usr/libexec/shotwell/shotwell-video-thumbnailer
# productivity
sudo dnf install -y gnumeric keepassx
#sudo dnf install -y vinagre

### GNOME tweaks ###
# GNOME Shell
sudo dnf install -y gnome-shell-extension-alternate-tab

########################
#### Customizations ####
########################
# set hostname
sudo hostnamectl set-hostname gelos
# sudo hostnamectl set-hostname erebus
# GNOME
dconf write /org/gnome/desktop/privacy/report-technical-problems false
dconf write /org/gnome/shell/enabled-extensions "['alternate-tab@gnome-shell-extensions.gcampax.github.com']"
dconf write /org/gnome/desktop/interface/clock-show-date true
dconf write /org/gnome/terminal/legacy/default-show-menubar false
dconf write /org/gnome/settings-daemon/peripherals/touchpad/natural-scroll true
dconf write /org/gnome/settings-daemon/peripherals/touchpad/tap-to-click true
dconf write /org/freedesktop/tracker/miner/files/index-recursive-directories "['&DESKTOP', '&DOCUMENTS', '&MUSIC', '&VIDEOS']"
dconf write /org/gnome/desktop/media-handling/autorun-never true
dconf write /org/gnome/desktop/datetime/automatic-timezone true
dconf write /org/gnome/nautilus/preferences/sort-directories-first true
mkdir -p $HOME/.config/gtk-3.0
echo -e "[Settings]\ngtk-application-prefer-dark-theme=1" > $HOME/.config/gtk-3.0/settings.ini
# Shotwell
dconf write /org/yorba/shotwell/preferences/files/commit-metadata true
dconf write /org/yorba/shotwell/preferences/files/use-lowercase-filenames true
dconf write /org/yorba/shotwell/preferences/ui/use-24-hour-time true
dconf write /org/yorba/shotwell/preferences/ui/hide-photos-already-imported true

### Firefox ###
sudo mkdir -p /usr/lib64/firefox/browser/defaults/preferences
