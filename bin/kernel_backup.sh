#!/bin/ksh

set -euo pipefail

cp -p /bsd.booted /obsd || FAIL=1
cp -p /bsd.rd /obsd.rd || FAIL=1

if [[ "${FAIL}" == '1' ]]; then
	echo "Failed to back up /bsd kernel."
	return 1
fi
