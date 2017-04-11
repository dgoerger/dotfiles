### SECURITY ###
# see `man update-crypto-policies`
default['workstation']['crypto-policy'] = 'FUTURE'

### DNS ###
# set up dnsmasq as local caching resolver
default['workstation']['dnsmasq'] = true
# set up dnscrypt for encrypted lookups - not for corporate networks, probably
default['workstation']['dnscrypt_providers'] = {
  # dnscrypt provider => localhost port to use
  'primary' => {
      'dnscrypt.eu-dk' => '40'
    },
  'secondary' => {
      'dnscrypt.eu-nl' => '41'
    },
  'tertiary' => {
      'dnscrypt.eu-dk-ipv6' => '42'
    }
  }
# unencrypted dns providers, use only if 'dnscrypt_providers' is
default['workstation']['dns_providers'] = {
  'google-dns' => '8.8.8.8',
  'opendns' => '208.67.222.222',
  'verisign' => '64.6.64.6'
  }

### PERFORMANCE ###
# see `man tuned-profiles`
default['workstation']['tuned_profile'] = 'powersave'

### PACKAGES ###
# packages every machine should have
default['workstation']['packages'] = [
  # all-around useful
  'bsdtar',
  'colordiff',
  'git-core',
  'git-core-doc',
  'htop',
  'lsof',
  'ncdu',
  'nmap',
  'tmux',
  'tree',
  'vim-enhanced',
  # command-line productivity
  'cyrus-sasl-plain',# needed by mutt for plain auth
  'fuse-sshfs',
  'gdouros-symbola-fonts',# emoji support
  'kpcli',
  'lynx',
  'hunspell-en',# why isn't en-CA packaged separately?
  'mutt',
  'newsbeuter',
  'pandoc',
  'ranger',
  'unzip',# needed by vim for reading epub
  'youtube-dl',
  # daemons
  'chrony',
  'dnsmasq',
  'firewalld',
  'powertop',
  'rkhunter',
  'rsyslog',
  'tuned'
  ]
# LaTeX
default['workstation']['texlive'] = [
  'texlive-collection-xetex',
  'texlive-collection-luatex',
  'texlive-collection-latexrecommended',
  'texlive-collection-langenglish',
  'texlive-collection-mathextra'
  ]
# only install these if there's a graphical login manager enabled in systemd - assumes GNOME
default['workstation']['graphical_apps'] = [
  'firefox',
  'gedit-plugin-codecomment',
  'gedit-plugin-multiedit',
  'gedit-plugin-wordcompletion',
  'gnome-shell-extension-alternate-tab',
  'gstreamer1-plugins-bad-free',
  'keepassx',
  'latexila'
  ]
