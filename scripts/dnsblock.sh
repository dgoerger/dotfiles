#!/bin/bash

UPSTREAM_HOSTS_FILE='https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts'

## paths
NAMED_DIR='/etc/named'
NAMED_RPZ_FILE="${NAMED_DIR}/rpz.zone"
NETWORKMANAGER_DIR='/etc/NetworkManager/dnsmasq.d'
NETWORKMANAGER_BLOCKLIST_FILE="${NETWORKMANAGER_DIR}/blocklist.conf"
DNSMASQ_DIR='/etc/dnsmasq.d'
DNSMASQ_BLOCKLIST_FILE="${DNSMASQ_DIR}/blocklist.conf"
TMP='/var/tmp'
SRC="${TMP}/hostfile.src"
TMP_RPZ="${TMP}/rpz"
TMP_DNSMASQ="${TMP}/dnsmasq"


## functions
function build_for_isc_bind () {
  # build BIND9 RPZ zone file
  echo '$TTL 3H' | tee ${TMP_RPZ} >/dev/null 2>&1
  echo '@                       SOA LOCALHOST. blocked (1 1h 15m 30d 2h)' | tee --append ${TMP_RPZ} >/dev/null 2>&1
  echo '                        NS  LOCALHOST.' | tee --append ${TMP_RPZ} >/dev/null 2>&1
  echo '' | tee --append ${TMP_RPZ} >/dev/null 2>&1
  awk '$1 == "0.0.0.0" {print $2, "CNAME", "."}' ${SRC} | grep -vE "^[0-9].*[0-9] CNAME \.$" | tee --append ${TMP_RPZ} >/dev/null 2>&1

  # copy in the new dnsblock policy
  if [[ -f ${NAMED_RPZ_FILE} ]]; then
    cp -p "${NAMED_RPZ_FILE}" "${NAMED_RPZ_FILE}.bak"
  fi
  cp "${TMP_RPZ}" "${NAMED_RPZ_FILE}"
  chown root:named "${NAMED_RPZ_FILE}"
  chmod 0444 "${NAMED_RPZ_FILE}"

  # load new blocklist
  if named-checkconf 2>&1; then
    systemctl restart named
  else
    if [[ -f "${NAMED_RPZ_FILE}.bak" ]]; then
      cp -p "${NAMED_RPZ_FILE}.bak" "${NAMED_RPZ_FILE}"
    else
      rm "${NAMED_RPZ_FILE}"
    fi
  fi
}

function build_for_dnsmasq () {
  # build for dnsmasq
  echo "# ipv4" | tee ${TMP_DNSMASQ} >/dev/null 2>&1
  awk '$1 == "0.0.0.0" {print "address=\"/" $2 "/0.0.0.0\""}' ${SRC} | tee --append ${TMP_DNSMASQ} >/dev/null 2>&1
  echo "# ipv6" | tee --append ${TMP_DNSMASQ} >/dev/null 2>&1
  awk '$1 == "0.0.0.0" {print "address=\"/" $2 "/::\""}' ${SRC} | tee --append ${TMP_DNSMASQ} >/dev/null 2>&1
}


## main
if curl -Lo ${SRC} ${UPSTREAM_HOSTS_FILE} 2>/dev/null; then
  # ISC BIND9
  if systemctl status named >/dev/null 2>&1; then
    build_for_isc_bind
  # NetworkManager's built-in support for dnsmasq
  elif systemctl status NetworkManager >/dev/null 2>&1; then
    build_for_dnsmasq
    cp ${TMP_DNSMASQ} ${NETWORKMANAGER_BLOCKLIST_FILE}
    chmod 0444 ${NETWORKMANAGER_BLOCKLIST_FILE}
  elif systemctl status dnsmasq >/dev/null 2>&1; then
    build_for_dnsmasq
    cp ${TMP_DNSMASQ} ${DNSMASQ_BLOCKLIST_FILE}
    chmod 0444 ${DNSMASQ_BLOCKLIST_FILE}
    systemctl restart dnsmasq
  fi
fi
