# /etc/profile.d/custom_aliases.sh

### restrictive umask for mortals
if [[ $UID -gt 199 ]] && [ "`id -gn`" == "`id -un`" ]; then
  umask 077
fi

### disable history and senseless dotfiles
export LESSHISTFILE=-
export HTOPRC=/dev/null
unset HISTFILE

### set EDITOR
export EDITOR=vim

### fix ls filename quoting nonsense
export QUOTING_STYLE=literal

### set system-wide python3 prefs
if [[ -r /usr/local/share/python3_startup.py ]]; then
  export PYTHONSTARTUP=/usr/local/share/python3_startup.py
fi

### user specific aliases and functions
alias bc='bc -l'
alias cal='cal -m'
if [[ -x /usr/bin/copr-cli ]] && [[ -n ${COPR} ]]; then
  alias copr-cli='copr-cli --config ${COPR}'
fi
if [[ -x /usr/bin/colordiff ]]; then
  alias diff='colordiff'
fi
alias disapprove='echo '\''ಠ_ಠ'\'''
if [[ -x /usr/bin/kpcli ]]; then
  alias kpcli='kpcli --histfile=/dev/null --readonly'
fi
alias l='ls -lh --color=auto'
alias la='ls -lha --color=auto'
alias less='less -RF'
alias ll='ls -lh --color=auto'
alias ls='ls --color=auto'
if [[ -x /usr/bin/mpv ]]; then
  alias dvd='mpv dvd://'
fi
if [[ -x /usr/bin/nmap ]]; then
  alias nmap='nmap --system-dns'
fi
if [[ -x /usr/bin/ranger ]]; then
  alias ranger='ranger -c'
fi
alias shrug="echo '¯\_(ツ)_/¯'"
if [[ -x /usr/bin/bsdtar ]]; then
  alias tar='bsdtar'
fi
alias tree='tree -N'
alias view='vim --cmd "let no_plugin_maps = 1" -c "runtime! macros/less.vim" -m -n'
alias weather='curl -4k https://wttr.in/?m'
if [[ -x /usr/bin/youtube-dl ]]; then
  alias youtube-dl='youtube-dl -f webm'
fi
