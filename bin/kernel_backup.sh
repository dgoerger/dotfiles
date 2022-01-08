#!/bin/ksh -
set -Cefuo pipefail

if [[ "$(uname)" != 'OpenBSD' ]]; then
	printf 'ERROR: Unsupported OS\n' && exit 1
fi

cp -p /bsd.booted /obsd
cp -p /bsd.rd /obsd.rd
