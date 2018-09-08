#!/bin/ksh

TMPFILE="$(mktemp -t pf.XXXXXX)"
CONF="/usr/local/etc/pf_blocklist.conf"
chown root:_pkgfetch "${TMPFILE}"
chmod 0660 "${TMPFILE}"

if [[ "$(uname)" != 'OpenBSD' ]]; then
  echo 'ERROR: Unsupported OS' && return 1
fi

# kludge to avoid a race condition with the dnsblock script reloading unbound
sleep 90

# download IP blocklists and parse
su -s/bin/sh _pkgfetch -c "/usr/bin/ftp -VMo - https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/bds_atif.ipset \
https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/et_block.netset \
https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/et_compromised.ipset \
https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level1.netset \
https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level2.netset \
https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level3.netset \
https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_abusers_1d.netset \
https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_abusers_30d.netset \
https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_proxies.netset | awk '/^[1-9].*[0-9]$/ {print $1}' | sort -uV > ${TMPFILE}"

# block Shodan
su -s/bin/sh _pkgfetch -c "/usr/bin/ftp -VMo - https://isc.sans.edu/api/threatlist/shodan/shodan.txt | grep -Eo '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}' >> ${TMPFILE}"

# copy into place
if [[ -f "${CONF}" ]]; then
  cp -p "${CONF}" "${CONF}.bak"
fi
cp "${TMPFILE}" "${CONF}"
chown root:wheel "${CONF}"
chmod 0440 "${CONF}"

# verify syntax and reload pf
if pfctl -nf /etc/pf.conf 2>/dev/null; then
  pfctl -f /etc/pf.conf
else
  mv "${CONF}.bak" "${CONF}"
  echo "Invalid PF syntax, backing out blocklist update, please verify." | mailx -s "pf: failed to verify updated blocklist" root
fi
