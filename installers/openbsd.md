Postinstall Guide for OpenBSD 6.1 - 6.5
========================================


Hardware
---------

  - [Full-disk
    encryption](https://www.bsdnow.tv/tutorials/fde#OpenBSD)


Linode
-------

  - [installing a custom
    distribution](https://www.linode.com/docs/tools-reference/custom-kernels-distros/install-a-custom-distribution-on-a-linode/#install-a-custom-distribution)

  - installer disk: 400MB


Common
-------

  1. copy in user-level dotfiles

  2. pkg_add, for example:

```
pkg_add abook colordiff git kpcli lynx mutt--sasl ncdu neovim \
newsboat privoxy rclone shellcheck sysclean tor toot unzip wtf \
xlsx2csv yabitrot

pkg_add chromium exiv2 ffmpeg firefox keepassxc mpv \
noto-cjk noto-emoji openconnect--light sct st wpa_supplicant \
xwallpaper youtube-dl
```

  3. copy in sysconfs, for example:

    - manuals_tab_completion.sh

    - /etc/sysctl.conf

    - /var/unbound/etc/unbound.conf

    - /etc/chromium/policies/managed/policy.json

    - /usr/local/lib/firefox/distribution/policies.json

  4. configure DNS

```
ftp -o /var/unbound/etc/named.cache \
https://www.internic.net/domain/named.cache
unbound-anchor -a /var/unbound/db/root.key
ftp -o /var/unbound/etc/unbound.conf \
https://david.goerger.info/files/dotfiles/sysconfs/unbound.conf
rcctl enable unbound
mkdir -p /usr/local/etc
touch /usr/local/etc/blocklist.conf
rcctl start unbound
sh /usr/local/sbin/dnsblock
echo -e "interface \"em0\" {\\n  supersede domain-name \
\"${dnsbase}\";\\n  supersede domain-name-servers 127.0.0.1;\\n \
request subnet-mask, broadcast-address, time-offset, routers;\\n \
require subnet-mask;\\n}" | tee /etc/dhclient.conf
sh /etc/netstart
```

  5. set crons, for example:

```
@weekly /usr/local/sbin/sysclean
@daily /usr/local/sbin/dnsblock
@daily /usr/local/sbin/manuals_tab_completion
@daily /usr/sbin/pkg_add -Dsnap -Uu >/dev/null 2>&1
@daily /usr/sbin/rcctl restart httpd >/dev/null
57 * * * * /usr/local/sbin/pf_blocklist
```
