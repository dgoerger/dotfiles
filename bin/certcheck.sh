#!/bin/ksh -
set -Cefuo pipefail

EXPIRY_THRESHOLD_WARNING=15
EXPIRY_THRESHOLD_CRITICAL=5
TLS_PROTOCOL_VERSION=''

usage() {
	printf 'usage:\n    certcheck HOSTNAME [PORT]\n'
}

while getopts ":0:1:2:3:" option; do
	case "${option}" in
		0) export TLS_PROTOCOL_VERSION='-tls1' && shift ;;
		1) export TLS_PROTOCOL_VERSION='-tls1_1' && shift ;;
		2) export TLS_PROTOCOL_VERSION='-tls1_2' && shift ;;
		3) export TLS_PROTOCOL_VERSION='-tls1_3' && shift ;;
		*)
			usage
			exit 3
			;;
	esac
done

# set port number
if [[ "$#" == '1' ]]; then
	PORT=443
elif [[ "$#" == '2' ]]; then
	case ${2} in
		''|*[!0-9]*)
			printf 'ERROR: port number must be an integer\n\n'
			usage
			exit 1
			;;
		*)
			PORT="${2}"
			;;
	esac
else
	usage
	exit 1
fi

# set hostname
if getent hosts "${1}" >/dev/null 2>&1; then
	FQDN="${1}"
elif [[ "$(uname)" == 'Darwin' ]] && [[ -n "$(dscacheutil -q host -a name "${1}" 2>/dev/null)" ]]; then
	FQDN="${1}"
else
	printf "ERROR: cannot find %s in DNS.\n" "${1}"
	exit 1
fi

# set protocol-specific flags
if [[ "${PORT}" == '21' ]]; then
	# protocol == starttls (ftp/21)
	PROTOCOL_FLAGS="${TLS_PROTOCOL_VERSION} -starttls ftp"
elif [[ "${PORT}" == '25' ]] || [[ "${PORT}" == '587' ]]; then
	# protocol == starttls (smtp/25, smtp-submission/587)
	PROTOCOL_FLAGS="${TLS_PROTOCOL_VERSION} -starttls smtp"
elif [[ "${PORT}" == '110' ]]; then
	# protocol == starttls (pop3/110)
	PROTOCOL_FLAGS="${TLS_PROTOCOL_VERSION} -starttls pop3"
elif [[ "${PORT}" == '143' ]] || [[ "${PORT}" == '220' ]]; then
	# protocol == starttls (imap/143, imap3/220)
	PROTOCOL_FLAGS="${TLS_PROTOCOL_VERSION} -starttls imap"
elif [[ "${PORT}" == '5222' ]] || [[ "${PORT}" == '5269' ]]; then
	# protocol == starttls (xmpp-client/5222, xmpp-server/5269)
	PROTOCOL_FLAGS="${TLS_PROTOCOL_VERSION} -starttls xmpp"
else
	# protocol == tls+sni (https/443, smtps/465, ldaps/636, imaps/993, xmpps/5223, https-tomcat/8443, etc)
	PROTOCOL_FLAGS="${TLS_PROTOCOL_VERSION} -servername ${FQDN}"
fi

# query certificate
QUERY="$(echo Q | openssl s_client ${PROTOCOL_FLAGS} -connect "${FQDN}:${PORT}" 2>/dev/null)"
CERTIFICATE_AUTHORITY="$(echo "${QUERY}" | sed 's/\ =\ /=/g' | awk -F'CN=' '/^issuer=/ {print $2}')"
ROOT_AUTHORITY="$(echo "${QUERY}" | grep -E '^Certificate chain$' -A4 | tail -n1 | sed 's/\ =\ /=/g' | awk -F'CN=' '/i:/ {print $2}')"
TLS_PROTOCOL="$(echo "${QUERY}" | awk '/Protocol  :/ {print $NF}')"
EXPIRY_DATE="$(echo "${QUERY}" | openssl x509 -noout -enddate 2>/dev/null | awk -F'=' '/notAfter/ {print $2}')"
CHAIN_OF_TRUST_STATUS="$(echo "${QUERY}" | awk '/Verify return code:/ {print $4}' | head -n1)"

# best-effort estimation of whether the certificate is valid for the queried domain
if [[ "$(echo "${FQDN}" | tr -cd . | wc -c)" -ge 2 ]]; then
	DOMAIN_WILDCARD="$(echo "\*.$(echo "${FQDN}" | cut -d. -f2-)")"
else
	DOMAIN_WILDCARD="${FQDN}"
fi
if echo "${QUERY}" | openssl x509 -text | grep -q "DNS:${FQDN}"; then
	VALID_FOR_DOMAIN=0
elif echo "${QUERY}"  | openssl x509 -text | grep -q "DNS:${DOMAIN_WILDCARD}"; then
	VALID_FOR_DOMAIN=0
else
	VALID_FOR_DOMAIN=1
fi

# error if we can't find a certificate
if [[ -z "${EXPIRY_DATE}" ]]; then
	printf "UNKNOWN: certificate %s:%s is unreachable\n" "${FQDN}" "${PORT}"
	exit 1
fi

# print certificate authority info
if [[ -z "${ROOT_AUTHORITY}" ]]; then
	ROOT_AUTHORITY='??'
fi
printf "Issuer: %s -> %s\n" "${CERTIFICATE_AUTHORITY}" "${ROOT_AUTHORITY}"

# print expiry date
printf "Expiry: %s\n" "${EXPIRY_DATE}"

# calculate the number of days to expiry
if [[ "$(uname)" == 'Linux' ]]; then
	SECONDS_TO_EXPIRY="$(echo "$(date --date="${EXPIRY_DATE}" +%s) - $(date +%s)" | bc -l)"
else
	SECONDS_TO_EXPIRY="$(echo "$(date -jf "%b %e %H:%M:%S %Y %Z" "${EXPIRY_DATE}" +%s) - $(date +%s)" | bc -l)"
fi
DAYS_TO_EXPIRY="$(echo "scale=0; ${SECONDS_TO_EXPIRY} / 86400" | bc -l)"

# print overall status
if [[ "${CHAIN_OF_TRUST_STATUS}" != '0' ]]; then
	printf "Status: CRITICAL - cannot be determined to be authentic (chain-of-trust)\n"
elif [[ "${SECONDS_TO_EXPIRY}" -lt '0' ]]; then
	printf "Status: CRITICAL - already expired\n"
elif [[ "${DAYS_TO_EXPIRY}" -le "${EXPIRY_THRESHOLD_CRITICAL}" ]]; then
	printf "Status: CRITICAL - expires in %s day(s)\n" "${DAYS_TO_EXPIRY}"
elif [[ "${VALID_FOR_DOMAIN}" != '0' ]]; then
	printf "Status: WARNING - possible domain mismatch\n"
elif [[ "${DAYS_TO_EXPIRY}" -le "${EXPIRY_THRESHOLD_WARNING}" ]]; then
	printf "Status: WARNING - expires in %s day(s)\n" "${DAYS_TO_EXPIRY}"
else
	printf "Status: OK - expires in %s day(s)\n" "${DAYS_TO_EXPIRY}"
fi
