# /etc/profile.d/custom.sh

# more restrictive umask for mortals
if [ $UID -gt 199 ] && [ "`id -gn`" == "`id -un`" ]; then
  umask 027
fi

# disable history and senseless dotfiles
export LESSHISTFILE=-
export HTOPRC=/dev/null
unset HISTFILE

# set EDITOR
export EDITOR=vim

# fix ls filename quoting nonsense
export QUOTING_STYLE=literal

# user specific aliases and functions
alias bc='bc -l'
alias cal='cal -m'
if [ -f /usr/bin/colordiff ]; then
  alias diff='colordiff'
fi
alias forecast='curl -4k https://wttr.in/?m'
if [ -f /usr/bin/google-chrome ]; then
  alias google-chrome-socks='/usr/bin/google-chrome --proxy-server="socks://127.0.0.1:1080"'
fi
alias grep='grep --color=always'
if [ -f /usr/bin/irssi ]; then
  alias irssi='irssi --config=/dev/null'
fi
if [ -f /usr/bin/kpcli ]; then
  alias kpcli='kpcli --histfile=/dev/null --readonly'
fi
alias l='ls -lh --color'
alias la='ls -lha --color'
alias less='less -RF'
alias ll='ls -lh --color'
alias ls='ls --color'
if [ -f /usr/bin/lynx ]; then
  alias lynx='lynx -use_mouse -vikeys -nomore -noprint -tna -force_empty_hrefless_a -enable_scrollback -cookies -noreferer https://duckduckgo.com/'
fi
if [ -f /usr/bin/newsbeuter ]; then
  alias newsbeuter="newsbeuter -q -C /etc/newsbeuter.conf -u ${NEWSBEUTER}"
fi
if [ -f /usr/bin/podbeuter ]; then
  alias podbeuter='podbeuter -a'
fi
if [ -f /usr/bin/ranger ]; then
  alias ranger='ranger -c'
fi
alias shrug="echo '¯\_(ツ)_/¯'"
#function shrug() {
#  echo "¯\_(ツ)_/¯"
#}
if [ -f /usr/bin/bsdtar ]; then
  alias tar='bsdtar'
fi
alias tree='tree -N'
if [ -f /usr/bin/nvim ]; then
  alias view='nvim --cmd "let no_plugin_maps = 1" -c "runtime! macros/less.vim" -R'
else
  alias view='vim --cmd "let no_plugin_maps = 1" -c "runtime! macros/less.vim" -R'
fi
alias weather='curl -4k https://wttr.in/?m'
if [ -f /usr/bin/youtube-dl ]; then
  alias youtube-dl='youtube-dl -f webm'
fi