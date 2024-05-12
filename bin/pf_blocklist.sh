#!/bin/ksh -
set -Cefuo pipefail

if [[ "$(uname)" != 'OpenBSD' ]]; then
	printf 'ERROR: Unsupported OS\n'
	exit 1
fi

readonly CONF="/etc/pf.conf.deny"
readonly TMPFILE="$(mktemp -t pf.XXXXXX)"

chown root:_pkgfetch "${TMPFILE}"
chmod 0660 "${TMPFILE}"

# download IP blocklists and parse
/usr/bin/su -s/bin/ksh _pkgfetch -c "/usr/bin/ftp -Vo - \
https://iplists.firehol.org/files/firehol_level1.netset \
awk '/^[1-9].*[0-9]$/' | cut -d ' ' -f1 | sort -uV | tee ${TMPFILE}" >/dev/null

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
