#!/bin/sh

UPSTREAM_HOSTS_FILE='https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts'

TMP='/tmp/unbound'
SRC='/tmp/hostfile.src'
CONF_DIR='/usr/local/etc'
BLOCKLIST_FILE="${CONF_DIR}/blocklist.conf"
PRIVOXY_TMP='/tmp/privoxy'
PRIVOXY_CONF='/etc/privoxy/dnsblock.action'

case "$(uname)" in
  OpenBSD) FETCHER='/usr/bin/ftp -VMo' ;;
  Linux) FETCHER='/usr/bin/curl -sLo' ;;
  NetBSD) FETCHER='/usr/bin/ftp -o' ;;
  *) echo 'ERROR: Unsupported OS' && exit 1 ;;
esac

# first verify we can reach upstream
if ${FETCHER} ${SRC} ${UPSTREAM_HOSTS_FILE} 2>/dev/null; then
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
        rcctl restart unbound >/dev/null 2>&1
      # Linux with systemd
      elif systemctl is-enabled unbound; then
        systemctl restart unbound >/dev/null 2>&1
      fi
    elif [ -f "${BLOCKLIST_FILE}.bak" ]; then
      mv "${BLOCKLIST_FILE}.bak" "${BLOCKLIST_FILE}"
    fi
    if [ -d /etc/privoxy ]; then
      # generate a Privoxy blocklist while we're at it
      echo '{ +block{dnsblock} }' | tee "${PRIVOXY_TMP}" >/dev/null 2>&1
      awk '$1 == "0.0.0.0" {print $2}' "${SRC}" | tee -a "${PRIVOXY_TMP}" >/dev/null 2>&1
      if privoxy --config-test --chroot /etc/privoxy >/dev/null 2>&1; then
        if [ -f "${PRIVOXY_CONF}" ]; then
          cp -p "${PRIVOXY_CONF}" "${PRIVOXY_CONF}.bak"
        fi
        mv "${PRIVOXY_TMP}" "${PRIVOXY_CONF}"
        if [ -f /etc/rc.d/privoxy ]; then
          rcctl restart privoxy >/dev/null 2>&1
        elif systemctl is-enabled privoxy; then
          systemctl restart privoxy >/dev/null 2>&1
        fi
      fi
    fi
    rm "${TMP}" "${SRC}"
  else
    echo 'ERROR: Unbound not running.'
    exit 1
  fi
else
  echo "ERROR: Upstream blocklist is unreachable via ${FETCHER}."
  exit 1
fi
