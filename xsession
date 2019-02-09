# ~/.xsession
/usr/local/bin/sct 3000
/usr/X11R6/bin/xsetroot -grey
/usr/X11R6/bin/setxkbmap us mac
/usr/local/bin/feh --bg-tile --zoom fill --no-fehbg ${HOME}/.config/wallpaper/current &
export ENV=${HOME}/.profile
/usr/X11R6/bin/cwm
