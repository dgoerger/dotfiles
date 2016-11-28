default['workstation']['crypto-policy'] = 'FUTURE'
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
  'pandoc-static',
  'ranger',
  'unzip',# needed by vim for reading epub
  'youtube-dl'
  ]
default['workstation']['texlive'] = [
  'texlive-collection-xetex',
  'texlive-collection-luatex',
  'texlive-collection-latexrecommended',
  'texlive-collection-langenglish',
  'texlive-collection-mathextra'
  ]
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
