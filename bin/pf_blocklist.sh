#!/bin/ksh -
set -Cefuo pipefail

if [[ "$(uname)" != 'OpenBSD' ]]; then
	printf 'ERROR: Unsupported OS\n'
	exit 1
fi

CONF="/etc/pf.conf.deny"; readonly CONF
TMPFILE="$(mktemp -t pf.XXXXXX)"; readonly TMPFILE

# sources
BLOCKLISTDE_BOTS='https://lists.blocklist.de/lists/bots.txt'
BLOCKLISTDE_LONGTERM='http://lists.blocklist.de/lists/strongips.txt'
BLOCKLISTDE_TELEPHONY='http://lists.blocklist.de/lists/sip.txt'
DSHIELD_TOP20='https://feeds.dshield.org/block.txt'
GREENSNOW='https://blocklist.greensnow.co/greensnow.txt'
SPAMHAUS_DROP_V4='https://www.spamhaus.org/drop/drop.txt'
SPAMHAUS_DROP_V6='https://www.spamhaus.org/drop/dropv6.txt'
STOPFORUMSPAM='https://www.stopforumspam.com/downloads/toxic_ip_cidr.txt'

chown root:_pkgfetch "${TMPFILE}"
chmod 0660 "${TMPFILE}"

# download IP blocklists and parse
/usr/bin/su -s/bin/ksh _pkgfetch -c "/usr/bin/ftp -VMo - \
        ${BLOCKLISTDE_BOTS} ${BLOCKLISTDE_LONGTERM} ${BLOCKLISTDE_TELEPHONY} \
        ${GREENSNOW} ${SPAMHAUS_DROP_V4} ${SPAMHAUS_DROP_V6} ${STOPFORUMSPAM} | \
        awk '/^[1-9]/' | cut -d ' ' -f1 | \
        sort -uV | tee -a ${TMPFILE}" >/dev/null
/usr/bin/su -s/bin/ksh _pkgfetch -c "/usr/bin/ftp -VMo - \
        ${DSHIELD_TOP20} | \
        awk '/^[1-9]/ {print \$1, \$3}' | \
        sed 's/\ /\//' | sort -uV | tee -a ${TMPFILE}" >/dev/null

# copy into place
if [[ -f "${CONF}" ]]; then
	cp -p "${CONF}" "${CONF}.bak"
fi
install -pm 0440 -o root -g wheel "${TMPFILE}" "${CONF}"
rm "${TMPFILE}"

# verify syntax and reload pf
if pfctl -nf /etc/pf.conf 2>/dev/null; then
	pfctl -f /etc/pf.conf
else
	mv "${CONF}.bak" "${CONF}"
	printf "Invalid PF syntax, backing out blocklist update. Please verify.\n"
	exit 1
fi
