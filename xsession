# ~/.xsession

# screen colour temperature (i.e. redshift/f.lux)
if [[ -x /usr/local/bin/sct ]]; then
	/usr/local/bin/sct 3000
fi
# keyboard layout
/usr/X11R6/bin/setxkbmap us mac
# background
/usr/X11R6/bin/xsetroot -solid "#252123"
if [[ -x /usr/local/bin/xwallpaper ]] && [[ -r ${HOME}/.config/wallpaper/current ]]; then
	/usr/local/bin/xwallpaper --center ${HOME}/.config/wallpaper/current
fi
# load ~/.profile in ksh(1) interactive shells
export ENV=${HOME}/.profile
# launch the calm window manager
/usr/X11R6/bin/cwm
