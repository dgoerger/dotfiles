#!/bin/bash

##### CHANGEME #####
# fqdn hostname
FQDN=host.change.me
# gpu - supports 'intel' or 'nvidia' - if nvidia, auto-enable NEGATIVO17.org multimedia repo
GPU=intel
# use Google's official version of Chrome ?
GOOGLE_CHROME=no


### usage
function usage () {
  echo -e "\
A Fedora Workstation x86_64 postinstall script.\\n\
\\n\
Usage:\\n\
\\n\
  $ # customize the CHANGEME section\\n\
  $ vi postinstall.sh\\n\
  $ # run the script\\n\
  $ sh postinstall.sh\\n"
}


### bomb out if we're doing it wrong
if [[ "$(uname -m)" != "x86_64" ]]; then
  usage
  return 1
fi
if [[ "${GPU}" == 'nvidia' ]]; then
  if sudo bootctl status 2>/dev/null | grep -q 'Secure Boot: enabled'; then
    echo "!! WARNING: Secure Boot detected !!"
    echo "- This script will NOT re-sign your kernel. Aborting."
    echo "  Please disable Secure Boot before proceeding."
    return 1
  fi
fi

### confirm selections
echo ""
echo "You're about to configure this machine with the following parameters:"
echo "  - Google Chrome: ${GOOGLE_CHROME}"
echo "  - Hostname/FQDN: ${FQDN}"
echo "  - GPU type: ${GPU}"
echo ""
echo "Proceed? (y/N)"
read -r yesno
if [[ "${yesno}" != "y" ]] && [[ "${yesno}" != "Y" ]] && [[ "${yesno}" != "yes" ]]; then
  echo ""
  echo "No action taken."
  echo ""
  return 20
fi


########################
## Remove extraneous  ##
########################
# hardware
sudo dnf remove -y atmel-firmware foomatic* fprintd glusterfs* gnome-boxes \
hpijs hplip-common hyperv* iscsi-initiator-utils libfprint \
libiscsi libvirt* memtest86+ NetworkManager-adsl NetworkManager-team \
open-vm-tools openvpn pptp qemu* sane-backends spice* tigervnc* vpnc xen*

# dev tools and libs
sudo dnf remove -y abrt* cyrus-sasl-gssapi devassistant* fpaste java* libreport \
perl setroubleshoot* yum-metadata-parser

# help and accessibility - re-add later if needed
sudo dnf remove -y gnome-classic-session orca yelp*

# remove for security
sudo dnf remove -y evince-browser-plugin httpd*

# misc unused graphical programs
sudo dnf remove -y baobab bijiben cheese empathy evolution file-roller flatpak \
ghostscript gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-contacts \
gnome-documents gnome-font-viewer gnome-logs gnome-maps gnome-music gnome-software gnome-system-monitor gnome-weather libreoffice* \
rhythmbox sane-backends-libs shotwell transmission-*

# remove the fullscreen pinentry dialogue for gpg2, i.e. default to cli prompt
sudo dnf remove -y pinentry-gnome3

# disable avahi - we aren't running any public Zeroconf services locally
sudo systemctl disable --now avahi-daemon.service

# disable modemmanager
sudo systemctl disable --now ModemManager

# disable CUPS
sudo systemctl disable --now cups.service
sudo systemctl disable --now cups.socket
sudo systemctl disable --now cups.path

# disable chrony's socket
sudo curl -Lo /etc/chrony.conf https://raw.githubusercontent.com/dgoerger/dotfiles/master/sysconfs/chrony.conf
sudo systemctl restart chronyd

# clean up and patch
sudo dnf autoremove -y
sudo dnf upgrade -y

### rkhunter initial system index
sudo dnf install -y rkhunter
sudo rkhunter --propupd


########################
### Hardware support ###
########################
## graphics
if [[ "$GPU" == "nvidia" ]]; then
  sudo dnf config-manager --add-repo=https://negativo17.org/repos/fedora-multimedia.repo
  sudo dnf install -y nvidia-driver kernel-devel dkms-nvidia nvidia-driver-cuda cuda nvidia-xconfig
  sudo nvidia-xconfig
  sudo systemctl enable dkms
  sudo dkms autoinstall
fi
## broken lenovo wifi driver
echo "blacklist ideapad_laptop" | sudo tee /etc/modprobe.d/lenovo_wifi.conf

########################
####### Software #######
########################
## firewall policy
sudo firewall-cmd --set-default-zone=drop
# optional apps
if [[ "$GOOGLE_CHROME" == "yes" ]]; then
  sudo dnf install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
fi

### security ###
sudo firewall-cmd --lockdown-on
sudo touch /etc/cron.allow
#sudo curl -Lo /etc/sudoers https://raw.githubusercontent.com/dgoerger/dotfiles/master/sysconfs/sudoers
sudo dnf install -y rsyslog
sudo systemctl enable --now rsyslog

### hostname
sudo hostnamectl set-hostname "${FQDN}"

### dns
sudo dnf install -y unbound ksh
sudo curl -Lo /etc/NetworkManager/NetworkManager.conf https://raw.githubusercontent.com/dgoerger/dotfiles/master/sysconfs/NetworkManager.conf
sudo curl -Lo /usr/local/sbin/dnsblock https://raw.githubusercontent.com/dgoerger/dotfiles/master/bin/dnsblock.sh
sudo chmod 0544 /usr/local/sbin/dnsblock
sudo touch /usr/local/etc/blocklist.conf
sudo curl -Lo /etc/unbound/unbound.conf https://raw.githubusercontent.com/dgoerger/dotfiles/master/sysconfs/unbound.conf
# Fedora doesn't support running unbound in a chroot - rhbz#1113947
sudo sed -i 's/\ \ \#chroot/\ \ chroot/' /etc/unbound/unbound.conf
sudo sed -i 's/\/var\/unbound\/db\/root\.key/\/var\/lib\/unbound\/root\.key/' /etc/unbound/unbound.conf
sudo systemctl restart NetworkManager
echo 'nameserver 127.0.0.1' | sudo tee /etc/resolv.conf
sudo systemctl enable --now unbound

### harmonize bsd/linux
sudo ln /usr/libexec/openssh/sftp-server /usr/libexec/sftp-server
sudo curl -Lo /etc/ssh/sshd_config https://raw.githubusercontent.com/dgoerger/dotfiles/master/sysconfs/sshd_config
sudo sed -i 's/\#\ UsePAM/UsePAM/' /etc/ssh/sshd_config
sudo chmod 0444 /etc/ssh/sshd_config
sudo systemctl enable --now sshd

### why isn't this in skel??
sudo mkdir -m0700 /etc/skel/.ssh
sudo touch /etc/skel/.ssh/authorized_keys
sudo chmod 0600 /etc/skel/.ssh/authorized_keys
sudo touch /etc/skel/.ssh/config
sudo chmod 0600 /etc/skel/.ssh/config

### GNOME fixes
sudo mkdir -m0755 /etc/dconf/db/gdm.d
sudo curl -Lo /etc/dconf/profile/gdm https://raw.githubusercontent.com/dgoerger/dotfiles/master/sysconfs/dconf_profile_gdm
sudo chmod 0444 /etc/dconf/profile/gdm
sudo curl -Lo /etc/dconf/db/gdm.d/00_site_settings https://raw.githubusercontent.com/dgoerger/dotfiles/master/sysconfs/dconf_settings_gdm
sudo chmod 0444 /etc/dconf/db/gdm.d/00_site_settings
sudo mkdir -m0755 /etc/dconf/db/site.d
sudo curl -Lo /etc/dconf/profile/user https://raw.githubusercontent.com/dgoerger/dotfiles/master/sysconfs/dconf_profile_user
sudo chmod 0444 /etc/dconf/profile/user
sudo curl -Lo /etc/dconf/db/site.d/00_site_settings https://raw.githubusercontent.com/dgoerger/dotfiles/master/sysconfs/dconf_settings_user
sudo chmod 0444 /etc/dconf/db/site.d/00_site_settings
sudo dconf update
sudo curl -Lo /etc/polkit-1/rules.d/55-prohibit-shutdown.rules https://raw.githubusercontent.com/dgoerger/dotfiles/master/sysconfs/polkit_prohibit-shutdown.rules
sudo chmod 0444 /etc/polkit-1/rules.d/55-prohibit-shutdown.rules
sudo curl -Lo /etc/polkit-1/rules.d/15-permit-usbs.rules https://raw.githubusercontent.com/dgoerger/dotfiles/master/sysconfs/polkit_permit-usbs.rules
sudo chmod 0444 /etc/polkit-1/rules.d/15-permit-usbs.rules

### apps
sudo dnf install -y bsdtar chromium colordiff git gnome-shell-extension-alternate-tab gnome-tweak-tool keepassxc kpcli lynx mg mosh ncdu neovim nmap pandoc rsync ShellCheck tmux tree
sudo curl -Lo /etc/firefox/pref/user.js https://raw.githubusercontent.com/dgoerger/dotfiles/master/sysconfs/firefox.js
sudo chmod 0444 /etc/firefox/pref/user.js
sudo curl -Lo /etc/chromium/master_preferences https://raw.githubusercontent.com/dgoerger/dotfiles/master/sysconfs/chromium.json
sudo chmod 0444 /etc/chromium/master_preferences
sudo curl -Lo /usr/local/bin/pomodoro https://raw.githubusercontent.com/dgoerger/dotfiles/master/bin/pomodoro.sh
sudo chmod 0445 /usr/local/bin/pomodoro

########################
##  First-user Setup  ##
########################
# set some ~/.ssh perms so we don't have to deal with it later
mkdir -p "$HOME/.ssh"
chmod 0700 "$HOME/.ssh"
touch "$HOME/.ssh/authorized_keys"
chmod 0600 "$HOME/.ssh/authorized_keys"
touch "$HOME/.ssh/config"
chmod 0600 "$HOME/.ssh/config"
