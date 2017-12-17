#!/bin/sh
#
# pf_update
#   Blocks nasties at the system firewall.
#

## Emerging Threats ruleset
DROP_FILE='pf.et.conf'
PF_MAIN='/etc/pf.conf'
PF_CONF_DIR='/usr/local/etc'
PF_DROP_CONF="${PF_CONF_DIR}/${DROP_FILE}"
TMP_FILE="/tmp/${DROP_FILE}"
SOURCE='https://rules.emergingthreats.net/fwrules/emerging-PF-ALL.rules'

# sanity check
if [ ! -f "${PF_MAIN}" ] || [ ! -x "$(which pfctl 2>/dev/null)" ]; then
  echo 'This script only supports pf.'
  exit 1
fi

# fetch updated ruleset
if ftp -VMo "${TMP_FILE}" "${SOURCE}" 2>/dev/null; then
  if pfctl -nf "${TMP_FILE}" 2>/dev/null; then
    mkdir -p "${PF_CONF_DIR}"
    if [ -f "${PF_DROP_CONF}" ]; then
      mv "${PF_DROP_CONF}" "${PF_DROP_CONF}.bak"
    fi
    mv "${TMP_FILE}" "${PF_DROP_CONF}"
    chown root:wheel "${PF_DROP_CONF}"
    chmod 0400 "${PF_DROP_CONF}"
    if pfctl -nf "${PF_MAIN}" 2>/dev/null; then
      pfctl -f "${PF_MAIN}"
    fi
  else
    echo 'Please verify the Emerging Threats upstream download URL.' | mail -s 'pf: failed to verify ET droplist' root
  fi
else
  echo 'Please verify the Emerging Threats upstream download URL.' | mail -s 'pf: failed to download ET droplist' root
fi

## scour ssh logs for bruteforcers AND BLOCK
# TODO ipv6
# block anyone trying to auth to system accounts
awk '/^[1-9].*[0-9]$/ /Disconnecting authenticating user (root|daemon|operator|bin|build|sshd|www|nobody|_).*Too many authentication failures/ {print $10}' /var/log/authlog | sort -u | while read -r ip; do
  pfctl -t bruteforce -T add "${ip}" >/dev/null 2>&1
done
# block IPs with repeated invalid username login attempts (n>2)
awk '/^[1-9].*[0-9]$/ /Disconnecting invalid user.*Too many authentication failures/ {print $10}' /var/log/authlog | sort | uniq -c | awk '$1 > 2 {print $2}' | while read -r ip; do
  pfctl -t bruteforce -T add "${ip}" >/dev/null 2>&1
done

## scan for obvious spammers and mxsploiters AND BLOCK
awk '/smtp event=failed-command.*command="AUTH LOGIN"/ {gsub ("address=","",$9); print $9}' /var/log/maillog | sort -u | while read -r ip; do
  pfctl -t bruteforce -T add "${ip}" >/dev/null 2>&1
done
