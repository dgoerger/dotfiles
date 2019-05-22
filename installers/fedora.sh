#!/bin/bash

##### CHANGEME #####
# fqdn hostname
FQDN=host.change.me
# use Google's official version of Chrome?
GOOGLE_CHROME=no


### usage
usage() {
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


### hardware check
if [[ "$(uname -m)" != "x86_64" ]]; then
  usage
  return 1
fi
if [[ -n "$(lspci | awk '/VGA compatible controller: NVIDIA/')" ]]; then
  GPU=nvidia
fi
if [[ "${GPU}" == 'nvidia' ]]; then
  if sudo bootctl status 2>/dev/null | grep -q 'Secure Boot: enabled'; then
    echo "!! WARNING: Secure Boot detected !!"
    echo "- This script will NOT re-sign your kernel. Aborting."
    echo "  Please disable Secure Boot before proceeding."
    return 1
  fi
fi
if [[ -x "$(/usr/bin/which dnf 2>/dev/null)" ]]; then
  PKG='/usr/bin/dnf'
else
  PKG='/usr/bin/rpm-ostree'
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
# disable avahi - we aren't running any public Zeroconf services locally
sudo systemctl disable --now avahi-daemon.service

# disable modemmanager
sudo systemctl disable --now ModemManager

# disable CUPS
sudo systemctl disable --now cups.service
sudo systemctl disable --now cups.socket
sudo systemctl disable --now cups.path


########################
### Hardware support ###
########################
## graphics
if [[ "$GPU" == "nvidia" ]] && [[ "${PKG}" == '/usr/bin/dnf' ]]; then
  # TODO: add support for Nvidia/rpm-ostree
  sudo dnf config-manager --add-repo=https://negativo17.org/repos/fedora-nvidia.repo
  sudo dnf install -y nvidia-driver kernel-devel dkms-nvidia nvidia-driver-cuda cuda nvidia-xconfig
  sudo nvidia-xconfig
  sudo systemctl enable dkms
  sudo dkms autoinstall
fi

########################
####### Software #######
########################
if [[ "$GOOGLE_CHROME" == "yes" ]]; then
  sudo "${PKG}" install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
fi

### security ###
sudo firewall-cmd --set-default-zone=drop
sudo firewall-cmd --lockdown-on
sudo touch /etc/cron.allow
sudo "${PKG}" install -y rsyslog
sudo systemctl enable --now rsyslog
ln -sf /tmp /var/tmp

### hostname
sudo hostnamectl set-hostname "${FQDN}"

### harmonize bsd/linux
sudo ln /usr/libexec/openssh/sftp-server /usr/libexec/sftp-server

### why isn't this in skel??
sudo mkdir -m0700 /etc/skel/.ssh
sudo touch /etc/skel/.ssh/authorized_keys
sudo chmod 0600 /etc/skel/.ssh/authorized_keys
sudo touch /etc/skel/.ssh/config
sudo chmod 0600 /etc/skel/.ssh/config

### apps
sudo "${PKG}" install -y bsdtar chromium colordiff firefox git \
gnome-shell-extension-alternate-tab gnome-tweak-tool keepassxc kpcli \
ksh lynx mg mosh ncdu neovim nmap pandoc rsync ShellCheck tmux tree

########################
##  First-user Setup  ##
########################
# set some ~/.ssh perms so we don't have to deal with it later
mkdir -p -m 0700 "$HOME/.ssh"
touch "$HOME/.ssh/authorized_keys"
chmod 0600 "$HOME/.ssh/authorized_keys"
touch "$HOME/.ssh/config"
chmod 0600 "$HOME/.ssh/config"
