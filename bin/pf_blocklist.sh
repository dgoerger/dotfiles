#!/bin/ksh

set -efuo pipefail

CONF="/etc/pf.conf.deny"
TMPFILE="$(mktemp -t pf.XXXXXX)"

chown root:_pkgfetch "${TMPFILE}"
chmod 0660 "${TMPFILE}"

if [[ "$(uname)" != 'OpenBSD' ]]; then
	printf 'ERROR: Unsupported OS\n' && return 1
fi

# download IP blocklists and parse
/usr/bin/su -s/bin/ksh _pkgfetch -c "/usr/bin/ftp -Vo - https://www.binarydefense.com/banlist.txt \
https://rules.emergingthreats.net/blockrules/compromised-ips.txt \
https://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt \
https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level1.netset \
https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level2.netset | awk '/^[1-9].*[0-9]$/' | cut -d ' ' -f1 | sort -uV > ${TMPFILE}"

# block Shodan
/usr/bin/su -s/bin/sh _pkgfetch -c "/usr/bin/ftp -Vo - https://isc.sans.edu/api/threatlist/shodan/shodan.txt | grep -Eo '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}' >> ${TMPFILE}"

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
	printf "Invalid PF syntax, backing out blocklist update, please verify.\n" | mailx -s "pf: failed to verify updated blocklist" root
fi
