#!/bin/ksh

cp -p /bsd.booted /obsd || FAIL=1
cp -p /bsd.rd /obsd.rd || FAIL=1

if [[ -e /bsd.sp ]]; then
	cp -p /bsd.sp /obsd.sp || FAIL=1
fi

if [[ "${FAIL}" == '1' ]]; then
	echo "Failed to back up /bsd kernel."
	return 1
fi
