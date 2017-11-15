#!/bin/sh

# NB: gui notification only works if SELinux is disabled
#     ^ (alternatively, TODO write an SELinux policy)
#
# TODO: non-portable reliance on GNU coreutils 'date'
#
# TODO: non-portable use of GNU 'ps' - on *BSD always returns "ttys=''"
#
# TODO: non-portable reliance on machinectl, qdbus, notify-send
#
# TODO: what's the correct xenocara proc to grep on *BSD?


## prep broadcast
# fetch REBOOT_DELAY (in minutes) if passed in as an argument
case ${1} in
  ''|*[!0-9]*) echo "not an integer" >/dev/null ;;
  *) REBOOT_DELAY=${1} ;;
esac
# else set a sane default for adequate pre-reboot warning
if [ -z "${REBOOT_DELAY}" ]; then
  REBOOT_DELAY=5
fi
REBOOT_DELAY_STRING="${REBOOT_DELAY} minutes"
REBOOT_TIME="$(date --date="${REBOOT_DELAY_STRING}" +%H:%M)"
REBOOT_GRAPHICAL_BANNER="SYSTEM REBOOT AT ${REBOOT_TIME}"
REBOOT_GRAPHICAL_MESSAGE='Please save your work and log out.'
REBOOT_WALL_MESSAGE='Pending reboot - please save your work and log out.'

## issue reboot command - notifies shell users
/sbin/shutdown -r +${REBOOT_DELAY} "${REBOOT_WALL_MESSAGE}"

## notify graphical users
notify() {
# leverage libnotify to alert graphical users
if [ -n "$(ps h -o tty -C 'Xwayland' 2>/dev/null)" ]; then
  # Wayland
  ttys="$(ps h -o tty -C 'Xwayland' 2>/dev/null)"
elif [ -n "$(ps h -o tty -C 'Xorg' 2>/dev/null)" ]; then
  # X11
  ttys="$(ps h -o tty -C 'Xorg' 2>/dev/null)"
else
  # no graphics!
  ttys=''
fi
for tty in ${ttys}; do
  # normal console logins
  if [ -n "${tty}" ] && [ "${tty}" != '?' ]; then
    x_user=$(LANG='' who -u | grep "^[^ ]\+[ ]\+${tty}" | cut -d ' ' -f 1)
    if [ -n "${x_user}" ] && [ "$(getent passwd "${x_user}")" ]; then
      /usr/bin/machinectl shell "${x_user}@" /usr/bin/notify-send "${REBOOT_GRAPHICAL_BANNER}" "${REBOOT_GRAPHICAL_MESSAGE}" --icon=dialog-warning-symbolic --urgency=critical
    fi
  fi
done
}

detect_pending_reboot() {
  if [ "$(uname)" = 'Linux' ]; then
    # reboot has been moved to the session / logind per https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdVersionOfShutdown
    result=$(qdbus --literal --system org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.DBus.Properties.Get org.freedesktop.login1.Manager ScheduledShutdown | awk -F'"' '{print $2}')
    if [ "${result}" = "reboot" ]; then
      return 0
    else
      return 1
    fi
  elif [ "$(uname)" = 'OpenBSD' ]; then
    if [ -n "$(pgrep shutdown)" ]; then
      return 0
    else
      return 1
    fi
  else
    # else hope someone kills this proc manually (if necessary) and it doesn't go on looping forever
    return 0
  fi
}

while detect_pending_reboot; do
  # User matrix:
  # 1) logged in before shutdown command is issued (x < T)
  # 2) logged in between shutdown command and pre-reboot lockdown (T < x < R - 5)
  # 3) no users can log in when (R - 5 < x < R) - see `man 8 shutdown`
  #
  # Shell/SSH notifications:
  # - these broadcast every minute for free via `wall` thanks to `shutdown`
  #
  # Graphical notifications:
  # 1) first group receives initial notification (but might appreciate a reminder)
  # 2) second group needs a notification later
  # 3) third group does not exist
  #
  # Special case: second group does not exist (T = R - 5) when (REBOOT_DELAY=5)

  # issue reminder every minute - not perfect but we solve all cases eh
  notify
  sleep 60
done
