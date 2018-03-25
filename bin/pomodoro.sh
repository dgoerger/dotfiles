#!/bin/ksh

usage="Usage:\
  pomodoro [minutes] [message]\
"

# sanity checks
if [[ ! -x "$(/usr/bin/which notify-send 2>/dev/null)" ]] || [[ -z "${DESKTOP_SESSION}" ]]; then
  echo 'This only works in a graphical environment.'
  return 1
elif [[ ! -x "$(/usr/bin/which tmux 2>/dev/null)" ]]; then
  echo 'Please install tmux.'
  return 1
elif [[ $# -ne 2 ]]; then
  echo "${usage}"
  return 1
else
  message="${2}"
fi

case ${1} in
  ''|*[!0-9]*) echo "Error: \${1} must be an integer." && return 1 ;;
  *) delay=${1} ;;
esac

# main
/usr/bin/tmux new -d "sleep $(echo "${delay}*60" | bc -l); notify-send POMODORO ${message} --icon=dialog-warning-symbolic --urgency=critical"
