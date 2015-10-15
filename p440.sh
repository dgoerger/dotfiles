#!/bin/bash

########################
## Remove unnecessary ##
########################
sudo dnf remove -y abrt* b43* baobab bijiben cheese devassistant* dos2unix dnf-yum empathy evince-browser-plugin evolution foomatic* fpaste fprintd glusterfs* gnome-boxes gnome-characters gnome-classic-session gnome-clocks gnome-contacts gnome-documents gnome-music gnome-software gnome-system-monitor gnome-weather hpijs hplip-common httpd* hyperv* iscsi-initiator-utils iwl* java* libfprint libiscsi libreoffice* libreport libvirt* memtest86+ NetworkManager-adsl NetworkManager-team openvpn orca perl pptp python qemu* rhythmbox sane-backends setroubleshoot* shotwell spice* tigervnc* totem transmission-gtk vpnc xen* yelp* yum-metadata-parser
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
sudo dnf install -y git tmux traceroute vim-enhanced vim-fugitive
# monitoring
sudo dnf install -y bmon htop iotop iptraf-ng lsof ncdu
# productivity
sudo dnf install -y pandoc-static
# security
sudo dnf install -y firewalld nmap
sudo systemctl enable firewalld
sudo firewall-cmd --set-default-zone=drop

### system libraries ###
# spellcheck
sudo dnf install -y hunspell-en

### graphical applications ###
# productivity
sudo dnf install -y gnumeric keepassx vinagre
# sudo dnf install -y gnome-boxes
### GNOME tweaks ###
# GNOME Shell
sudo dnf install -y gnome-shell-extension-alternate-tab

########################
#### Customizations ####
########################
echo 'erebus' | sudo tee /etc/hostname
# GNOME
dconf write /org/gnome/shell/enabled-extensions "['alternate-tab@gnome-shell-extensions.gcampax.github.com']"
dconf write /org/gnome/desktop/interface/clock-show-date true
dconf write /org/gnome/terminal/legacy/default-show-menubar false
dconf write /org/gnome/settings-daemon/peripherals/touchpad/natural-scroll true
dconf write /org/gnome/settings-daemon/peripherals/touchpad/tap-to-click true
dconf write /org/freedesktop/tracker/miner/files/index-recursive-directories "['&DOCUMENTS']"
dconf write /org/gnome/desktop/media-handling/autorun-never true
dconf write /org/gnome/desktop/datetime/automatic-timezone false
dconf write /org/gnome/nautilus/preferences/sort-directories-first true

### Firefox ###
sudo mkdir -p /usr/lib64/firefox/browser/defaults/preferences
