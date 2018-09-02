#!/bin/ksh

TMPDIR="$(mktemp -d)"
TMPFILE="$(mktemp)"
CONF="/usr/local/etc/pf_blocklist.conf"

case "$(uname)" in
  OpenBSD) FETCH='/usr/bin/ftp -VM' ;;
  *) echo 'ERROR: Unsupported OS' && return 1 ;;
esac

# download IP blocklists and parse
cd "${TMPDIR}"
${FETCH} https://www.binarydefense.com/banlist.txt
${FETCH} https://rules.emergingthreats.net/blockrules/compromised-ips.txt
${FETCH} https://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt
${FETCH} https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level1.netset
${FETCH} https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level2.netset
${FETCH} https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level3.netset
${FETCH} https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_abusers_1d.netset
${FETCH} https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_abusers_30d.netset
${FETCH} https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_proxies.netset
awk '/^[1-9].*[0-9]$/ {print $1}' *.txt *.netset | sort -uV > "${TMPFILE}"

# block Shodan
${FETCH} https://isc.sans.edu/api/threatlist/shodan/shodan.txt 
grep -Eo '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}' shodan.txt >> "${TMPFILE}"

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
