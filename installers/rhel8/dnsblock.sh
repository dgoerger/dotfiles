#!/bin/bash

UPSTREAM_HOSTS_FILE='https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts'

TMP="$(mktemp)"
SRC="$(mktemp)"
CONF_DIR='/usr/local/etc'
BLOCKLIST_FILE="${CONF_DIR}/blocklist.conf"
FETCHER='/usr/bin/curl -sLo'

export FETCH="${FETCHER} ${SRC} ${UPSTREAM_HOSTS_FILE}"

# first verify we can reach upstream
if ${FETCH} 2>/dev/null; then
  # build for unbound
  awk '$1 == "0.0.0.0" {print "local-zone: \""$2"\" always_nxdomain"}' "${SRC}" | tee "${TMP}" >/dev/null 2>&1
  # create a backup of any existing, working blocklist
  if [[ -f "${BLOCKLIST_FILE}" ]]; then
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
    systemctl restart unbound >/dev/null 2>&1
  elif [[ -f "${BLOCKLIST_FILE}.bak" ]]; then
    mv "${BLOCKLIST_FILE}.bak" "${BLOCKLIST_FILE}"
  else
    # if unbound-checkconf fails AND there is no backup blocklist.. remove the new blocklist
    rm "${BLOCKLIST_FILE}"
    touch "${BLOCKLIST_FILE}"
  fi

  rm "${TMP}" "${SRC}"
else
  echo 'ERROR: Upstream blocklist is unreachable.'
  return 1
fi
