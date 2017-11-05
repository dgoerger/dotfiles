#!/bin/sh

UPSTREAM_HOSTS_FILE='https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts'

# crontab doesn't necessarily have a full path
PATH=${PATH}:/usr/local/bin:/usr/local/sbin
export PATH

TMP='/tmp/unbound'
SRC='/tmp/hostfile.src'
CONF_DIR='/usr/local/etc'
BLOCKLIST_FILE="${CONF_DIR}/blocklist.conf"


build_for_unbound() {
  awk '$1 == "0.0.0.0" {print "local-zone: \""$2"\" static"}' ${SRC} | tee ${TMP} >/dev/null 2>&1
  if [ -f "${BLOCKLIST_FILE}" ]; then
    cp -p "${BLOCKLIST_FILE}" "${BLOCKLIST_FILE}.bak"
  fi
  mkdir -p "${CONF_DIR}"
  cp "${TMP}" "${BLOCKLIST_FILE}"
  chmod 0444 "${BLOCKLIST_FILE}"
  if /usr/sbin/unbound-checkconf >/dev/null 2>&1; then
    if [ -f /etc/rc.d/unbound ]; then
      /etc/rc.d/unbound restart
    fi
  elif [ -f "${BLOCKLIST_FILE}.bak" ]; then
    mv "${BLOCKLIST_FILE}.bak" "${BLOCKLIST_FILE}"
  fi
  rm "${TMP}" "${SRC}"
}


## main
if curl -Lo "${SRC}" "${UPSTREAM_HOSTS_FILE}" 2>/dev/null; then
  # unbound
  if pgrep unbound >/dev/null 2>&1; then
    build_for_unbound
  else
    echo 'ERROR: Unbound not running.'
    exit 1
  fi
else
  echo 'ERROR: Upstream blocklist unreachable OR cURL binary not in PATH.'
  exit 1
fi
