#!/bin/bash

##### CHANGEME #####
# graphics or headless
GRAPHICAL_INTERFACE=yes
# fqdn hostname
FQDN=gelos
# gpu - supports 'intel' or 'nvidia'
GPU=intel
# don't use powertop if usb peripherals start giving you trouble
POWERTOP=yes
# do we need an RDP client
RDP_CLIENT=no
# enable rpmfusion.org ?
RPMFUSION=no
# https://atom.io ?
ATOM_EDITOR=no
# use Google's official version of Chrome ?
GOOGLE_CHROME=no


### bomb out if we're doing it wrong
if [[ "$(uname -m)" != "x86_64" ]]; then
  echo "ERROR! This script is only compatible with x86_64."
  exit 1
fi
if [[ "$(id -u)" == "0" ]]; then
  echo "DON'T RUN AS ROOT! DID YOU READ THE SCRIPT BEFORE EXECUTING??"
  exit 1
fi


### confirm selections
echo ""
echo "You're about to configure this machine with the following parameters:"
echo "  - Graphical interface? ${GRAPHICAL_INTERFACE}"
echo "    - Atom text editor: ${ATOM_EDITOR}"
echo "    - Google Chrome: ${GOOGLE_CHROME}"
echo "    - RDP client: ${RDP_CLIENT}"
echo "  - Hostname/FQDN: ${FQDN}"
echo "  - GPU type (this script will NOT re-sign your kernel; careful of Secure Boot): ${GPU}"
# TODO we should probably sign out-of-band kernel modules
echo "  - Enable RPMFUSION repos? ${RPMFUSION}"
echo ""
echo "Proceed? (y/N)"
read yesno
if [[ "${yesno}" == "y" ]] || [[ "${yesno}" == "Y" ]] || [[ "${yesno}" == "yes" ]]; then
  continue
else
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
  sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora_version}.noarch.rpm
  sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-nonfree-release-${fedora_version}.noarch.rpm
  sudo dnf config-manager --add-repo=http://negativo17.org/repos/fedora-multimedia.repo
fi

########################
## Remove unnecessary ##
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
if [[ "$RPMFUSION" == "yes" ]]; then
  if [[ "$GPU" == "intel" ]]; then
    sudo dnf install -y libva-intel-driver
  elif [[ "$GPU" == "nvidia" ]]; then
    sudo dnf install -y nvidia-driver kernel-devel dkms-nvidia nvidia-driver-cuda cuda nvidia-xconfig
    sudo nvidia-xconfig
    sudo systemctl enable dkms
    sudo dkms autoinstall
    if [[ -f /usr/lib64/xorg/modules/extensions/libglx.so ]]; then
      # TODO: more elegant solution... notably needs to be re-done after every xorg update
      sudo ln -sf /usr/lib64/nvidia/xorg/libglx.so /usr/lib64/xorg/modules/extensions/libglx.so
    fi
  fi
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
else
  ## firewall policy
  sudo firewall-cmd --set-default-zone=drop
  # optional apps
  if [[ "$RPMFUSION" == "yes" ]]; then
    sudo dnf install -y gstreamer1-libav
  fi
  if [[ "$GOOGLE_CHROME" == "yes" ]]; then
    sudo dnf install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
  fi
  if [[ "$ATOM_EDITOR" == "yes" ]]; then
    sudo dnf copr enable mosquito/atom -y
    sudo dnf install -y atom
  fi
fi

### security ###
sudo firewall-cmd --lockdown-on
sudo chattr +i /etc/firewalld/firewalld.conf

### hostname
sudo hostnamectl set-hostname $FQDN
sudo chattr +i /etc/hostname

### chake it
sudo dnf install -y git-core rubygem-chake yum $(curl 'https://omnitruck.chef.io/stable/chef/metadata?p=el&pv=7&m=x86_64' 2>/dev/null | grep -E "^url" | awk -F" " '{print $2}')
sudo git clone https://github.com/dgoerger/dotfiles.git /var/chake --depth=1
echo -e "local://${FQDN}:\n  run_list:\n      - recipe[workstation]" | sudo tee /var/chake/nodes.yaml

########################
## First-user Cleanup ##
########################
## set some rc's
curl -Lo $HOME/.profile https://github.com/dgoerger/dotfiles/raw/master/profile
curl -Lo $HOME/.bashrc https://github.com/dgoerger/dotfiles/raw/master/bashrc
rm $HOME/.bash_logout
rm $HOME/.bash_profile
# set some ~/.ssh perms so we don't have to deal with it later
mkdir -p $HOME/.ssh
chmod 700 $HOME/.ssh
touch $HOME/.ssh/authorized_keys
chmod 600 $HOME/.ssh/authorized_keys
touch $HOME/.ssh/config
chmod 600 $HOME/.ssh/config
## why does this exist
rm -rf $HOME/.pki
ln -s /dev/null $HOME/.pki
ln -s ${XDG_RUNTIME_DIR} $HOME/.newsbeuter
## reminder to edit ~/.bashrc
echo ""
echo "Reminder: append MUTTRC and NEWSBEUTER to ~/.bashrc"
echo ""
