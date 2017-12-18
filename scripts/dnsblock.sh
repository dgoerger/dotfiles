#!/bin/sh

UPSTREAM_HOSTS_FILE='https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts'

TMP='/tmp/unbound'
SRC='/tmp/hostfile.src'
CONF_DIR='/usr/local/etc'
BLOCKLIST_FILE="${CONF_DIR}/blocklist.conf"

if [ "$(uname)" = 'OpenBSD' ]; then
  # cURL is in ports - presence is likely but not guaranteed
  binary='/usr/bin/ftp -VMo'
elif [ -x "$(/usr/bin/which curl 2>/dev/null)" ]; then
  # fallback to cURL if found
  binary='curl -sLo'
else
  # else exit
  echo 'ERROR: please ensure cURL is installed and in the PATH.'
  exit 1
fi

# first verify we can reach upstream
if "${binary}" "${SRC}" "${UPSTREAM_HOSTS_FILE}" 2>/dev/null; then
  if pgrep unbound >/dev/null 2>&1; then
    # build for unbound
    awk '$1 == "0.0.0.0" {print "local-zone: \""$2"\" always_nxdomain"}' ${SRC} | tee ${TMP} >/dev/null 2>&1
    # create a backup of any existing, working blocklist
    if [ -f "${BLOCKLIST_FILE}" ]; then
      cp -p "${BLOCKLIST_FILE}" "${BLOCKLIST_FILE}.bak"
    else
      # if this is a first-run, ensure the destination dir exists
      mkdir -p "${CONF_DIR}"
    fi
    # copy in the new blocklist
    cp "${TMP}" "${BLOCKLIST_FILE}"
    chmod 0444 "${BLOCKLIST_FILE}"
    # syntax check for sanity - we do NOT want to break the DNS!!
    if /usr/sbin/unbound-checkconf >/dev/null 2>&1; then
      # BSD
      if [ -f /etc/rc.d/unbound ]; then
        /etc/rc.d/unbound restart 2>/dev/null
      # Linux with systemd
      elif systemctl is-enabled unbound; then
        systemctl restart unbound 2>/dev/null
      fi
    elif [ -f "${BLOCKLIST_FILE}.bak" ]; then
      mv "${BLOCKLIST_FILE}.bak" "${BLOCKLIST_FILE}"
    fi
    rm "${TMP}" "${SRC}"
  else
    echo 'ERROR: Unbound not running.'
    exit 1
  fi
else
  echo 'ERROR: Upstream blocklist unreachable OR cURL binary not in PATH.'
  exit 1
fi
