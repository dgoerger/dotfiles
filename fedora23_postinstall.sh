#!/bin/bash

########################
### Additional repos ###
########################
#dnf install -y http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-22.noarch.rpm

########################
## Remove unnecessary ##
########################
sudo dnf remove -y abrt* b43* baobab bijiben cheese devassistant* dos2unix dnf-yum empathy evince-browser-plugin evolution foomatic* fpaste fprintd glusterfs* gnome-boxes gnome-characters gnome-classic-session gnome-clocks gnome-contacts gnome-documents gnome-system-monitor gnome-weather hpijs hplip-common httpd* hyperv* iscsi-initiator-utils iwl* java* libfprint libiscsi libreoffice* libreport libvirt* memtest86+ NetworkManager-adsl NetworkManager-team openvpn orca perl pptp python qemu* rhythmbox sane-backends setroubleshoot* spice* tigervnc* transmission-gtk vpnc xen* yelp* yum-metadata-parser
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
sudo dnf install -y git git-cal git-extras sl tig tmux traceroute vim-enhanced vim-fugitive
# monitoring
sudo dnf install -y bmon htop iotop iptraf-ng lsof ncdu
# productivity
sudo dnf install -y mutt pandoc-static transmission-cli
# security
sudo dnf install -y firewalld nmap ykpers
sudo systemctl enable firewalld
sudo firewall-cmd --set-default-zone=drop
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
# TODO: is the below still necessary for the Firefox dictionaries bug?
# why is Canadian English not packaged separately?
UNUSED_HUNSPELL="de_AT.aff de_LI.aff en_BS.aff en_DK.aff en_IE.aff en_NA.aff en_SG.aff en_ZM.aff es_BO.dic es_CU.dic es_GT.aff es_PA.aff es_SV.aff fr_BE.aff fr_LU.aff de_AT.dic de_LI.dic en_BS.dic en_DK.dic en_IE.dic en_NA.dic en_SG.dic en_ZM.dic es_CL.aff es_GT.dic es_PA.dic es_SV.dic fr_BE.dic fr_LU.dic de_BE.aff de_LU.aff en_BW.aff en_GB.aff en_IN.aff en_NG.aff en_TT.aff en_ZW.aff es_CL.dic es_DO.aff es_HN.aff es_PE.aff es_US.aff fr_CA.aff fr_MC.aff de_BE.dic de_LU.dic en_BW.dic en_GB.dic en_IN.dic en_NG.dic en_TT.dic en_ZW.dic es_CO.aff es_DO.dic es_HN.dic es_PE.dic es_US.dic fr_CA.dic fr_MC.dic de_CH.aff en_AG.aff en_BZ.aff en_GH.aff en_JM.aff en_NZ.aff es_CO.dic es_EC.aff es_MX.aff es_PR.aff es_UY.aff fr_CH.aff  de_CH.dic en_AG.dic en_BZ.dic en_GH.dic en_JM.dic en_NZ.dic es_AR.aff es_CR.aff es_EC.dic es_MX.dic es_PR.dic es_UY.dic fr_CH.dic en_AU.aff en_HK.aff en_MW.aff en_PH.aff en_ZA.aff es_AR.dic es_CR.dic es_ES.aff es_NI.aff es_PY.aff es_VE.aff en_AU.dic en_HK.dic en_MW.dic en_PH.dic en_ZA.dic es_BO.aff es_CU.aff es_ES.dic es_NI.dic es_PY.dic es_VE.dic"
for i in ${UNUSED_HUNSPELL}; do
  if [ -f "/usr/share/myspell/${i}" ]; then
    sudo rm "/usr/share/myspell/${i}"
  fi
done
### graphical applications ###
# multimedia
sudo dnf install -y gnome-music shotwell
# awful workaround for gnome#739396
sudo chmod 444 /usr/libexec/shotwell/shotwell-video-thumbnailer
# productivity
sudo dnf install -y keepassx
### GNOME tweaks ###
# GNOME Shell
sudo dnf install -y gnome-shell-extension-alternate-tab

########################
#### Customizations ####
########################
sudo hostname gelos
GITMAIL="dgoerger@users.noreply.github.com"
GITNAME="David Goerger"
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
# Locale
localectl set-locale LANG=en_CA.UTF-8
localectl set-x11-keymap us-mac mac
dconf write /system/locale/region "'en_CA.UTF-8'"
dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us+mac')]"
# vimrc
echo -e 'au BufReadCmd *.epub call zip#Browse(expand("<amatch>"))\nset viminfo="NONE"\nset paste' > $HOME/.vimrc
# gitconfig
echo -e "[user]\n    email = ${GITMAIL}\n    name = ${GITNAME}\n[push]\n    default = simple\n[color]\n    ui = true" > $HOME/.gitconfig
# bashrc
echo -e "# .bashrc\n\n# Source global definitions\nif [ -f /etc/bashrc ]; then\n        . /etc/bashrc\nfi\n\n# Uncomment the following line if you do not like the systemctl auto-paging feature:\n# export SYSTEMD_PAGER=\n\n# User specific aliases and functions\nalias view='vim -R'\nalias less='less -R'" > $HOME/.bashrc
# bash_profile
echo -e "# .bash_profile\n# Get the aliases and functions\nif [ -f ~/.bashrc ]; then\n  . ~/.bashrc\nfi\n# User specific environment and startup programs" > $HOME/.bash_profile
### Firefox ###
sudo mkdir -p /usr/lib64/firefox/browser/defaults/preferences
echo -e '### Mozilla User Preferences\n\n# neuter the hazard of ctrl+q\npref("browser.showQuitWarning", true);\n# disable sponsored tiles\npref("browser.newtabpage.directory.ping", "");\npref("browser.newtabpage.directory.source", "");\n# set DONOTTRACK header\npref("privacy.donottrackheader.enabled", true);\n# set spellcheck language as Canadian English moz#836230\npref("spellchecker.dictionary", "en_CA");\n# disable loading system colours - hazardous gtk dark\npref("browser.display.use_system_colors", false);\n# disable disk cache\npref("browser.cache.disk.enable", false);\npref("browser.cache.disk_cache_ssl", false);\npref("browser.cache.offline.enable", false);\n# enable tracking protection\npref("privacy.trackingprotection.enabled", true);\n# sane Firefox NoScript settings\nuser_pref("noscript.global", true);\nuser_pref("noscript.ctxMenu", false);\n# privacy\npref("browser.safebrowsing.downloads.enabled",false);\npref("browser.safebrowsing.malware.enabled",false);\npref("datareporting.healthreport.service.enabled",false);\npref("datareporting.healthreport.uploadEnabled",false);\npref("toolkit.telemetry.enabled",false);\npref("media.eme.enabled",false);\npref("media.gmp-eme-adobe.enabled",false);\npref("browser.pocket.enabled",false);\npref("browser.search.suggest.enabled",false);' | sudo tee /usr/lib64/firefox/browser/defaults/preferences/user.js >/dev/null
sudo mkdir -p /usr/lib64/firefox/browser/defaults/profile/chrome
echo -e '/*\n * * Place in /usr/lib64/firefox/browser/defaults/profile/chrome\n * * or in your local .mozilla/firefox/${profile}/chrome/ folder.\n * * Append with further fixes for websites which do not play\n * * nicely with Firefox GTK3 and a global GTK+ dark theme.\n * *\n * * NOTE: "\!important" overrides sites specified schema; only\n * *       use on sites with truly broken CSS. Lines without this\n * *       flag just provide saner defaults than what is shipped\n * *       in Firefox. See moz#519763.\n * */\n@-moz-document domain\(amtrak.com\) {\n  input {\n    color: black \!important;\n  }\n  select {\n    color: black \!important;\n  }\n}\n@-moz-document domain\(duckduckgo.com\) {\n  input.js-search-input {\n    color: black \!important;\n  }\n}\n@-moz-document domain\(runbox.com\) {\n  .formfield {\n    color: #e1eeff \!important;\n  }\n}' | sed 's/\\//g' | sudo tee /usr/lib64/firefox/browser/defaults/profile/chrome/userContent.css >/dev/null