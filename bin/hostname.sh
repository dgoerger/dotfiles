#!/bin/bash
#
# Arch Linux packages hostname(1) in the inetutils package
# alongside rsh, telnet, rlogin, ftpd, and talkd. Instead,
# here's a simple wrapper around hostnamectl(1).

if [[ -n "$(/usr/bin/hostnamectl --static)" ]]; then
	printf "%s\n" "$(/usr/bin/hostnamectl --static)"
elif [[ -n "$(/usr/bin/hostnamectl --transient)" ]]; then
	printf "%s\n" "$(/usr/bin/hostnamectl --transient)"
else
	printf 'hostname not found\n'
fi
