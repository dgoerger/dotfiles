#!/bin/bash

##### CHANGEME #####
# graphics or headless
GRAPHICAL_INTERFACE=yes
# fqdn hostname
FQDN=host.change.me
# gpu - supports 'intel' or 'nvidia'
GPU=intel
# do we need an RDP client
RDP_CLIENT=no
# enable rpmfusion.org ?
RPMFUSION=no
# enable Negativo17 ?
NEGATIVO17=no
# https://atom.io ?
ATOM_EDITOR=no
# use Google's official version of Chrome ?
GOOGLE_CHROME=no
# install Steam ?
STEAM_CLIENT=no


### usage
function usage () {
  echo -e "\
A Fedora Workstation x86_64 postinstall script.\n\
\n\
Usage:\n\
\n\
  $ # customize the CHANGEME section\n\
  $ vi postinstall.sh\n\
  $ # run the script\n\
  $ sh postinstall.sh\n"
}


### bomb out if we're doing it wrong
if [[ "$(uname -m)" != "x86_64" ]]; then
  usage
  exit 1
fi
if sudo bootctl status 2>/dev/null | grep -q 'Secure Boot: enabled'; then
  if [[ "${GPU}" == 'nvidia' ]]; then
    echo "!! WARNING: Secure Boot detected !!"
    echo "- This script will NOT re-sign your kernel. Aborting."
    echo "  Please disable Secure Boot before proceeding."
    exit 1
  fi
fi

### confirm selections
echo ""
echo "You're about to configure this machine with the following parameters:"
echo "  - Graphical interface? ${GRAPHICAL_INTERFACE}"
echo "    - Atom text editor: ${ATOM_EDITOR}"
echo "    - Google Chrome: ${GOOGLE_CHROME}"
echo "    - RDP client: ${RDP_CLIENT}"
echo "    - Steam client: ${STEAM_CLIENT}"
echo "  - Hostname/FQDN: ${FQDN}"
echo "  - GPU type: ${GPU}"
echo "  - Enable RPMFUSION repos? ${RPMFUSION}"
echo "  - Enable Negativo17 repos (auto-enabled if gpu == nvidia)? ${NEGATIVO17}"
echo ""
echo "Proceed? (y/N)"
read -r yesno
if [[ "${yesno}" != "y" ]] && [[ "${yesno}" != "Y" ]] && [[ "${yesno}" != "yes" ]]; then
  echo ""
  echo "No action taken."
  echo ""
  exit 20
fi


########################
### Additional repos ###
########################
if [[ "$RPMFUSION" == "yes" ]]; then
  fedora_version=$(uname -r | awk -F"." '{print $(NF-1)}' | grep -E "^fc" | awk -F"fc" '{print $2}')
  sudo dnf install -y "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora_version}.noarch.rpm"
  sudo dnf install -y "https://download1.rpmfusion.org/free/fedora/rpmfusion-nonfree-release-${fedora_version}.noarch.rpm"
fi
if [[ "${NEGATIVO17}" == "yes" ]] || [[ "${GPU}" == "nvidia" ]]; then
  sudo dnf config-manager --add-repo=https://negativo17.org/repos/fedora-multimedia.repo
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
sudo dnf remove -y baobab bijiben cheese empathy evolution file-roller \
ghostscript gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-contacts \
gnome-documents gnome-music gnome-software gnome-system-monitor gnome-weather libreoffice* \
rhythmbox shotwell transmission-*

# remove the fullscreen pinentry dialogue for gpg2, i.e. default to cli prompt
sudo dnf remove -y pinentry-gnome3

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
if [[ "$RPMFUSION" == "yes" ]] && [[ "$GPU" == "intel" ]]; then
    sudo dnf install -y libva-intel-driver
elif [[ "$GPU" == "nvidia" ]]; then
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
if [[ "$GRAPHICAL_INTERFACE" != "yes" ]]; then
  ## if there's no graphical interface, assume access is via ssh
  sudo firewall-cmd --set-default-zone=dmz
  sudo systemctl enable sshd
  sudo systemctl start sshd
else
  ## firewall policy
  sudo firewall-cmd --set-default-zone=drop
  # optional apps
  if [[ "$RPMFUSION" == "yes" ]]; then
    sudo dnf install -y gstreamer1-libav
    if [[ "$STEAM_CLIENT" == "yes" ]]; then
      sudo dnf install -y steam libCg.i636 libCg.x86_64
    fi
  fi
  if [[ "$GOOGLE_CHROME" == "yes" ]]; then
    sudo dnf install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
  fi
  if [[ "$ATOM_EDITOR" == "yes" ]]; then
    sudo dnf copr enable mosquito/atom -y
    sudo dnf install -y atom
  fi
  if [[ "$RDP_CLIENT" == "yes" ]]; then
    sudo dnf install -y remmina
  fi
fi

### security ###
sudo firewall-cmd --lockdown-on

### hostname
sudo hostnamectl set-hostname "${FQDN}"

########################
##  First-user Setup  ##
########################
# set some ~/.ssh perms so we don't have to deal with it later
mkdir -p "$HOME/.ssh"
chmod 0700 "$HOME/.ssh"
touch "$HOME/.ssh/authorized_keys"
chmod 600 "$HOME/.ssh/authorized_keys"
touch "$HOME/.ssh/config"
chmod 600 "$HOME/.ssh/config"
