#!/bin/ksh -
# Precompute an array for ksh(1) tab-completion of man(1).
#
# Motivation:
#   - tab-completion of manuals is helpful
#   - recomputing the array for each new login shell is costly
#   - the list of manuals doesn't change frequently
#
# Limitations:
#   - the list of manuals doesn't update until the next cron(8) run
#   - many manuals in section 1 don't correspond with an executable
#     and are thus filtered out (e.g. perl* and git-*)
#   - sections 2, 3, 3p, 4, and 9 are omitted for brevity

set -Cefuo pipefail

readonly CONFDIR="/usr/local/etc"
readonly CONFFILE="${CONFDIR}/manuals.list"
readonly PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/games:/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin
readonly TMPFILE="$(mktemp)"

if [[ ! -d "${CONFDIR}" ]]; then
	printf "ENOENT: directory '%s' does not exist\n" "${CONFDIR}"
        exit 1
elif [[ ! -w "${CONFDIR}" ]]; then
        printf "EACCES: cannot write to '%s'\n" "${CONFDIR}"
        exit 1
fi

# why is section 1 filled with so much junk?
man -M /usr/share/man:/usr/local/man:/usr/X11R6/man -s 1 -k Nm~. | cut -d\( -f1 | while read -r COMMAND; do if command -v "${COMMAND}" >/dev/null; then printf "%s\n" "${COMMAND}"; fi; done | tee "${TMPFILE}" >/dev/null
man -M /usr/share/man:/usr/local/man:/usr/X11R6/man -s 5 -k Nm~. | cut -d\( -f1 | tee -a "${TMPFILE}" >/dev/null
man -M /usr/share/man:/usr/local/man -s 6 -k Nm~. | cut -d\( -f1 | tee -a "${TMPFILE}" >/dev/null
man -M /usr/share/man:/usr/local/man -s 7 -k Nm~. | cut -d\( -f1 | tee -a "${TMPFILE}" >/dev/null
man -M /usr/share/man:/usr/local/man -s 8 -k Nm~. | cut -d\( -f1 | tee -a "${TMPFILE}" >/dev/null
tr -d , < "${TMPFILE}" | tr '[:space:]' '\n' | awk '/^[a-zA-Z]/' | sort -u | tee "${CONFFILE}" >/dev/null
chown root:wheel "${CONFFILE}"
chmod 0444 "${CONFFILE}"
rm "${TMPFILE}"
