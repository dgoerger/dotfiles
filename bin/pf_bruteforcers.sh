#!/bin/ksh

## sanity check
if ! /usr/bin/which pfctl >/dev/null 2>&1; then
  echo 'ERROR: this script requires pfctl'
  exit 1
fi

## restore table (e.g. after reboot)
if [[ -r /usr/local/etc/pf_bruteforcers.table ]]; then
  while read -r ip; do
    pfctl -t bruteforce -T add "${ip}" >/dev/null 2>&1
  done < /usr/local/etc/pf_bruteforcers.table
fi

## scour ssh logs for bruteforcers AND BLOCK
# TODO ipv6
# block anyone trying to auth to system accounts
awk '/^[1-9].*[0-9]$/ /Disconnecting authenticating user (root|daemon|operator|bin|build|sshd|www|nobody|_).*Too many authentication failures/ {print $10}' /var/log/authlog | sort -u | while read -r ip; do
  pfctl -t bruteforce -T add "${ip}" >/dev/null 2>&1
done
awk '/^[1-9].*[0-9]$/ /Disconnected from authenticating user (root|daemon|operator|bin|build|sshd|www|nobody|_)/ {print $11}' /var/log/authlog | sort -u | while read -r ip; do
  pfctl -t bruteforce -T add "${ip}" >/dev/null 2>&1
done
# block IPs with repeated invalid username login attempts (n>2)
awk '/^[1-9].*[0-9]$/ /Disconnecting invalid user.*Too many authentication failures/ {print $10}' /var/log/authlog | sort | uniq -c | awk '$1 > 2 {print $2}' | while read -r ip; do
  pfctl -t bruteforce -T add "${ip}" >/dev/null 2>&1
done
# block ssh port scanners who don't even try to log in
awk '/^[1-9].*[0-9]$/ /sshd.*Connection closed by [1-9].*\[preauth\]/ {print $9}' /var/log/authlog | sort | uniq -c | awk '$1 > 2 {print $2}' | while read -r ip; do
  pfctl -t bruteforce -T add "${ip}" >/dev/null 2>&1
done

## scan for obvious spammers and mxsploiters AND BLOCK
awk '/smtp event=failed-command.*command="AUTH LOGIN"/ {gsub ("address=","",$9); print $9}' /var/log/maillog | sort -u | while read -r ip; do
  pfctl -t bruteforce -T add "${ip}" >/dev/null 2>&1
done

## back up table
pfctl -t bruteforce -Ts > /usr/local/etc/pf_bruteforcers.table

## safety(?)
awk '/^[1-9].*[0-9]$/ /sshd.*Accepted password for/ {print $11}' /var/log/authlog | while read -r login_success; do
  if grep -q "${login_success}" /usr/local/etc/pf_bruteforcers.table; then
    pfctl -t bruteforce -T delete "${login_success}"
    cp /usr/local/etc/pf_bruteforcers.table{,.bak} | grep -v "${login_success}" /usr/local/etc/pf_bruteforcers.table.bak > tee /usr/local/etc/pf_bruteforcers.table
    echo "UNBANNING ${login_success}(!)" | /usr/bin/mailx -s "BREAK-IN ATTEMPT??" root
  fi
done
