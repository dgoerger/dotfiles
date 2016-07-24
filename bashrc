# .bashrc

# source global definitions
if [ -f /etc/bashrc ]; then
  source /etc/bashrc
fi

# show current git branch in prompt if applicable
if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
  source /usr/share/git-core/contrib/completion/git-prompt.sh
  PS1='\[\e[1;32m\]\h\[\e[0m\]\[\e[1;31m\]$(__git_ps1)\[\e[0m\]\[\e[1;30m\]\\\>\[\e[0m\] '
else
  PS1='\[\e[1;32m\]\h\[\e[0m\]\[\e[1;30m\]\\\>\[\e[0m\] '
fi

# disable history and senseless dotfiles
export LESSHISTFILE=-
export HTOPRC=/dev/null
unset HISTFILE

# set EDITOR
export EDITOR=vim

# fix ls filename quoting nonsense
export QUOTING_STYLE=literal

# connect to ssh socket on desktops
if [ -n "${DISPLAY}" ]; then
  export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
fi

# user specific aliases and functions
alias bc='bc -l'
if [ -f /usr/bin/colordiff ]; then
  alias diff='colordiff'
fi
alias grep='grep --color=always'
if [ -f /usr/bin/kpcli ]; then
  alias kpcli='kpcli --histfile=/dev/null'
fi
alias l='ls -lh --color'
alias la='ls -lha --color'
alias less='less -R'
alias lessc='vim --cmd "let no_plugin_maps = 1" -c "runtime! macros/less.vim" -R'
alias ll='ls -lh --color'
alias lowercase="sed -e 's/\(.*\)/\L\1/'"
alias ls='ls --color'
if [ -f /usr/bin/lynx ]; then
  alias lynx='lynx -use_mouse -vikeys -nomore -noprint -tna -force_empty_hrefless_a -enable_scrollback -cookies -noreferer https://duckduckgo.com/'
fi
if [ -f /usr/bin/podbeuter ]; then
  alias podbeuter='podbeuter -a'
fi
alias python='python3'
if [ -f /usr/bin/ranger ]; then
  alias ranger='ranger -c'
fi
if [ -f /usr/bin/bsdtar ]; then
  alias tar='bsdtar'
fi
alias tree='tree -N'
alias view='vim -R'
alias weather='curl http://wttr.in/?m'
if [ -f /usr/bin/youtube-dl ]; then
  alias youtube-dl='youtube-dl -f webm'
fi
