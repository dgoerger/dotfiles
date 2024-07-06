#!/bin/ksh -
# shellcheck disable=SC2174
set -Cfuo pipefail

umask 0027

SYSSTATS_DIR="/var/log/sysstats"; readonly SYSSTATS_DIR
DATETIME="$(date +%Y%m%d_%H%M)"; readonly DATETIME

if [[ ! -d "${SYSSTATS_DIR}" ]]; then
	mkdir -pm 0750 "${SYSSTATS_DIR}"
	chown root:wheel "${SYSSTATS_DIR}"
fi

# stats
df -lP | awk '/^\/dev/ {print $NF}' | while read -r FILESYSTEM; do
	fstat -f "${FILESYSTEM}" | grep -Ev "^USER"; done \
	| gzip > "${SYSSTATS_DIR}/${DATETIME}_fstat.gz"

netstat -an \
	| gzip > "${SYSSTATS_DIR}/${DATETIME}_netstat.gz"

ps -Awwfo user,pid,ppid,pgid,lstart,%cpu,%mem,stat,wchan,command \
	| gzip > "${SYSSTATS_DIR}/${DATETIME}_pstree.gz"

# cleanup
find "${SYSSTATS_DIR}" -type f -mtime +7 -delete
