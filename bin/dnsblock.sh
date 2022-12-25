#!/bin/ksh -
set -Cefuo pipefail

SRC="$(mktemp)"; readonly SRC
TMP="$(mktemp)"; readonly TMP
readonly UPSTREAM_HOSTS_FILE='https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts'

case "$(uname)" in
	Linux)
		readonly BLOCKLIST_FILE='/etc/unbound/blocklist.conf'
		readonly FETCH="/usr/bin/curl -sLo ${SRC} ${UPSTREAM_HOSTS_FILE}"
		;;
	OpenBSD)
		readonly BLOCKLIST_FILE='/etc/unwind.conf.deny'
		readonly FETCH="/usr/bin/ftp -Vo ${SRC} ${UPSTREAM_HOSTS_FILE}"
		;;
	*)
		printf 'ERROR: Unsupported OS\n'
		exit 1
		;;
esac

# first verify we can reach upstream
if ${FETCH} 2>/dev/null; then
	if pgrep -xu _unwind unwind >/dev/null 2>&1; then
		# build for unwind(8)
		awk '$1 == "0.0.0.0" {print $2}' "${SRC}" | tee "${TMP}" >/dev/null 2>&1
		# ref: https://support.mozilla.org/en-US/kb/canary-domain-use-application-dnsnet
		printf 'use-application-dns.net\n' | tee -a "${TMP}" >/dev/null 2>&1
	elif pgrep -xu unbound unbound >/dev/null 2>&1; then
		# build for unbound(8)
		awk '$1 == "0.0.0.0" {print "local-zone: \""$2"\" always_refuse"}' "${SRC}" | tee "${TMP}" >/dev/null 2>&1
		printf 'local-zone: "use-application-dns.net" always_refuse\n' | tee -a "${TMP}" >/dev/null 2>&1
	else
		printf 'ERROR: unsupported resolver\n'
		exit 1
	fi
	# create a backup of any existing, working blocklist
	if [[ -f "${BLOCKLIST_FILE}" ]]; then
		cp -p "${BLOCKLIST_FILE}" "${BLOCKLIST_FILE}.bak"
	fi
	# copy in the new blocklist
	install -pm 0444 -o root "${TMP}" "${BLOCKLIST_FILE}"

	# unwind(8)
	if rcctl ls on 2>/dev/null | grep -E "^unwind$" >/dev/null 2>&1; then
		rcctl restart unwind >/dev/null 2>&1
	# syntax check for sanity - we do NOT want to break the DNS!!
	elif /usr/sbin/unbound-checkconf >/dev/null 2>&1; then
		# OpenBSD
		if rcctl ls on 2>/dev/null | grep -E "^unbound$" 2>&1; then
			rcctl restart unbound >/dev/null 2>&1
		# Alpine
		elif rc-service unbound status >/dev/null 2>&1; then
			rc-service unbound restart
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
	exit 1
fi
