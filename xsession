# ~/.xsession

# screen colour temperature (i.e. redshift/f.lux)
/usr/local/bin/sct 3000
# keyboard layout
/usr/X11R6/bin/setxkbmap us mac
# background
/usr/X11R6/bin/xsetroot -grey
/usr/local/bin/feh --bg-tile --zoom fill --no-fehbg ${HOME}/.config/wallpaper/current &
# always use UTF-8
export LANG=en_CA.UTF-8
# load ~/.profile in ksh(1) interactive shells
export ENV=${HOME}/.profile
# launch the calm window manager
/usr/X11R6/bin/cwm
