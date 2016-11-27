default['dgoerger-workstation']['packages'] = [
  # hardware support
  'beignet',
  'mesa-vdpau-drivers',
  'libva-vdpau-driver',
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
  # command-line producitivity
  'gdouros-symbola-fonts',# emoji support
  'hunspell-en',# why isn't en-CA packaged separately?
  'pandoc-static',
  'unzip'# needed by vim for reading epub
  ]
default['dgoerger-workstation']['texlive'] = [
  'texlive-collection-xetex',
  'texlive-collection-luatex',
  'texlive-collection-latexrecommended',
  'texlive-collection-langenglish',
  'texlive-collection-mathextra'
  ]
default['dgoerger-workstation']['hostname'] = 'gelos'
