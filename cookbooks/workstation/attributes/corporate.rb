# intranets tend to have at least a few old things
override['workstation']['crypto-policy'] = 'DEFAULT'
# dnscrypt - not for corporate networks, probably
override['workstation']['dnscrypt_providers'] = []
# don't try to override corporate dns policy, default instead from DHCP
override['workstation']['dns_providers'] = []
