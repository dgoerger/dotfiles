#!/bin/bash
#
# TODO: non-portable use of GNU 'ps' - on *BSD always returns "ttys=''"
#
# TODO: non-portable reliance on machinectl


## prep broadcast
# fetch REBOOT_DELAY (in minutes) if passed in as an argument
case ${1} in
  ''|*[!0-9]*) echo "not an integer" >/dev/null ;;
  *) REBOOT_DELAY=${1} ;;
esac

# else set a sane default for adequate pre-reboot warning
if [[ -z "${REBOOT_DELAY}" ]]; then
  REBOOT_DELAY=5
fi

# bsd vs gnu `date`...
if [[ "$(uname)" == 'OpenBSD' ]]; then
  REBOOT_TIME="$(date -r "$(echo "$(date +%s)" + "${REBOOT_DELAY}*60" | bc -l)" +%H:%M)"
elif [[ "$(uname)" == 'Linux' ]]; then
  REBOOT_TIME="$(date --date="${REBOOT_DELAY} minutes" +%H:%M)"
else
  echo 'Unsupported operating system.'
  return 1
fi

# user-facing strings
REBOOT_GRAPHICAL_BANNER="SYSTEM REBOOT AT ${REBOOT_TIME}"
REBOOT_GRAPHICAL_MESSAGE='Please save your work and log out.'
REBOOT_WALL_MESSAGE='Pending reboot - please save your work and log out.'


## issue reboot command - notifies shell users
/sbin/shutdown -r +${REBOOT_DELAY} "${REBOOT_WALL_MESSAGE}"


## notify graphical users
notify() {
  if [[ "$(uname)" == 'OpenBSD' ]]; then
    # FIXME - doesn't work
    x_users="$(ps -p "$(pgrep -f Xsession)" -O user | awk '{print $2}' | grep -Ev "^USER$" | uniq)"
    for x_user in ${x_users}; do
      su -l "${x_user}" /usr/local/bin/notify-send "${REBOOT_GRAPHICAL_BANNER}" "${REBOOT_GRAPHICAL_MESSAGE}" --icon=dialog-warning-symbolic --urgency=critical
    done
  elif [[ "$(uname)" == 'Linux' ]]; then
    # notifications don't work if SELinux is enforcing
    if /usr/sbin/sestatus 2>/dev/null | grep -qE "Current mode.*enforcing" 2>/dev/null; then
      return 0
    fi
    # leverage libnotify to alert graphical users
    if [[ -n "$(ps h -o tty -C 'Xwayland' 2>/dev/null)" ]]; then
      # Wayland
      ttys="$(ps h -o tty -C 'Xwayland' 2>/dev/null)"
    elif [[ -n "$(ps h -o tty -C 'Xorg' 2>/dev/null)" ]]; then
      # X11
      ttys="$(ps h -o tty -C 'Xorg' 2>/dev/null)"
    else
      # no graphics!
      ttys=''
    fi
    for tty in ${ttys}; do
      # normal console logins
      if [[ -n "${tty}" ]] && [[ "${tty}" != '?' ]]; then
        x_user=$(LANG='' who -u | grep "^[^ ]\\+[ ]\\+${tty}" | cut -d ' ' -f 1)
        if [[ -n "${x_user}" ]] && [[ "$(getent passwd "${x_user}")" ]]; then
          /usr/bin/machinectl shell "${x_user}@" /usr/bin/notify-send "${REBOOT_GRAPHICAL_BANNER}" "${REBOOT_GRAPHICAL_MESSAGE}" --icon=dialog-warning-symbolic --urgency=critical
        fi
      fi
    done
  else
    # TODO amend if extended to other operating systems
    return 0
  fi
}

detect_pending_reboot() {
  if [[ "$(uname)" == 'OpenBSD' ]]; then
    if pgrep shutdown >/dev/null 2>&1; then
      return 0
    else
      return 1
    fi
  elif [[ "$(uname)" == 'Linux' ]]; then
    # reboot has been moved to the session / logind per https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdVersionOfShutdown
    result=$(qdbus --literal --system org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.DBus.Properties.Get org.freedesktop.login1.Manager ScheduledShutdown | awk -F'"' '{print $2}')
    if [[ "${result}" == 'reboot' ]]; then
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
