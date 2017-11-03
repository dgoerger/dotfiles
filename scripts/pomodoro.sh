#!/bin/sh

usage="Usage:\
  pomodoro [minutes] [message]\
"
if [ $# -ne 2 ]; then
  echo "${usage}"
  return 1
else
  message="${2}"
fi
case ${1} in
  ''|*[!0-9]*) echo "Error: \${1} must be an integer." && exit 1 ;;
  *) delay=${1} ;;
esac
if [ -n "${DESKTOP_SESSION}" ] && [ -x /usr/bin/notify-send ]; then
  # if running a desktop with Linux DBus available       
  /usr/bin/tmux new -d "sleep $(echo "${delay}*60" | /usr/bin/bc -l); /usr/bin/notify-send POMODORO ${message} --icon=dialog-warning-symbolic --urgency=critical"
else
  # otherwise assume we've a remote shell                
  /usr/bin/tmux new -d "sleep $(echo "${delay}*60" | /usr/bin/bc -l); echo ${message} | wall -g $(id -ng)"
fi
