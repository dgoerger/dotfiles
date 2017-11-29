#!/bin/sh

UPSTREAM_HOSTS_FILE='https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts'

# crontab doesn't necessarily have a full path - BSD cURL is in ports!
PATH=${PATH}:/usr/local/bin:/usr/local/sbin
export PATH

TMP='/tmp/unbound'
SRC='/tmp/hostfile.src'
CONF_DIR='/usr/local/etc'
BLOCKLIST_FILE="${CONF_DIR}/blocklist.conf"


# first verify we can reach upstream
if curl -Lo "${SRC}" "${UPSTREAM_HOSTS_FILE}" 2>/dev/null; then
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
      fi
      # Linux with systemd
      if systemctl is-enabled dnssec-triggerd; then
        # if Unbound is started by dnssec-triggerd, we have to do this dance (F27)
        pkill unbound
        systemctl restart dnssec-triggerd 2>/dev/null
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
