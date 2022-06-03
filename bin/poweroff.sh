#!/bin/ksh -
set -Cefuo pipefail

OS="$(uname)"; readonly "${OS}"

if [[ "${OS}" != 'OpenBSD' ]]; then
        printf "Unsupported operating system '%s'.\n" "${OS}"
fi

HOSTNAME="$(hostname -s)"; readonly "${HOSTNAME}"

printf 'Please enter the name of the machine to reboot: '
read -r MACHINE_NAME

if [[ "${HOSTNAME}" == "${MACHINE_NAME}" ]]; then
        if [[ "$(id -u)" == '0' ]]; then
                /sbin/shutdown -p now
        else
                /usr/bin/doas /sbin/shutdown -p now
        fi
else
        printf "Refusing to reboot '%s'...\n\n" "${HOSTNAME}"
        exit 1
fi
