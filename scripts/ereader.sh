#!/bin/ksh

usage="Usage:\
  ereader file.epub\
"

if [[ ! -x "$(/usr/bin/which pandoc 2>/dev/null)" ]]; then
  echo 'ERROR: please install pandoc'
  return 1
elif [[ ! -x "$(/usr/bin/which lynx 2>/dev/null)" ]]; then
  echo 'ERROR: please install lynx'
  return 1
fi

if [[ $# -ne 1 ]]; then
  echo "${usage}"
  return 1
elif [[ "${1}" = '-h' ]] || [[ "${1}" = '--help' ]]; then
  echo "${usage}"
  return 0
elif echo "${1}" | grep -Evq '\.epub$'; then
  echo "${usage}"
  return 1
elif ! ls "${1}" >/dev/null 2>&1; then
  echo "ERROR: file not found"
  return 1
else
  echo 'Reformatting.. (might take a moment)'
  pandoc -f epub -t html "${1}" | lynx -stdin
fi
