#!/bin/ksh

set -euo pipefail

UPSTREAM_HOSTS_FILE='https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts'

SRC="$(mktemp)"
TMP="$(mktemp)"
CONF_DIR='/usr/local/etc'
BLOCKLIST_FILE="${CONF_DIR}/blocklist.conf"

case "$(uname)" in
	Linux) FETCH="/usr/bin/curl -sLo ${SRC} ${UPSTREAM_HOSTS_FILE}" ;;
	OpenBSD) FETCH="/usr/bin/ftp -Vo ${SRC} ${UPSTREAM_HOSTS_FILE}" ;;
	*) printf 'ERROR: Unsupported OS\n' && return 1 ;;
esac

# first verify we can reach upstream
if ${FETCH} 2>/dev/null; then
	if pgrep -xu _unwind unwind >/dev/null 2>&1; then
		# build for unwind(8)
		awk '$1 == "0.0.0.0" {print $2}' "${SRC}" | tee "${TMP}" >/dev/null 2>&1
	else
		# build for unbound(8)
		awk '$1 == "0.0.0.0" {print "local-zone: \""$2"\" always_refuse"}' "${SRC}" | tee "${TMP}" >/dev/null 2>&1
		# ref: https://support.mozilla.org/en-US/kb/configuring-networks-disable-dns-over-https
		echo 'local-zone: "use-application-dns.net" always_nxdomain' | tee -a "${TMP}" >/dev/null 2>&1
	fi
	# create a backup of any existing, working blocklist
	if [[ -f "${BLOCKLIST_FILE}" ]]; then
		cp -p "${BLOCKLIST_FILE}" "${BLOCKLIST_FILE}.bak"
	elif [[ ! -d "${CONF_DIR}" ]]; then
		# if this is a first-run, ensure the destination dir exists
		mkdir -p "${CONF_DIR}"
	fi
	# copy in the new blocklist
	cp "${TMP}" "${BLOCKLIST_FILE}"
	chmod 0444 "${BLOCKLIST_FILE}"

	# unwind(8)
	if rcctl ls on 2>/dev/null | grep -qE "^unwind$"; then
		rcctl restart unwind >/dev/null 2>&1
	# syntax check for sanity - we do NOT want to break the DNS!!
	elif /usr/sbin/unbound-checkconf >/dev/null 2>&1; then
		# OpenBSD
		if rcctl ls on 2>/dev/null | grep -qE "^unbound$"; then
			rcctl restart unbound >/dev/null 2>&1
		# Linux with systemd
		elif systemctl is-enabled unbound >/dev/null 2>&1; then
			systemctl restart unbound >/dev/null 2>&1
		fi
	elif [[ -f "${BLOCKLIST_FILE}.bak" ]]; then
		mv "${BLOCKLIST_FILE}.bak" "${BLOCKLIST_FILE}"
	else
		# if unbound-checkconf fails AND there is no backup blocklist.. remove the new blocklist
		rm "${BLOCKLIST_FILE}"
		touch "${BLOCKLIST_FILE}"
		chmod 0444 "${BLOCKLIST_FILE}"
	fi

	rm "${TMP}" "${SRC}"
else
	printf 'ERROR: Upstream blocklist is unreachable.\n'
	return 1
fi
