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

# use vim mode instead of emacs mode
# see: http://www.catonmat.net/download/bash-vi-editing-mode-cheat-sheet.txt
set -o vi

# user specific aliases and functions
alias dnf='sudo dnf'
alias grep='grep --color=always'
alias l='ls -lh --color'
alias la='ls -lha --color'
alias less='less -R'
alias lowercase="sed -e 's/\(.*\)/\L\1/'"
alias lynx='lynx -use_mouse -vikeys -nomore -noprint -tna -force_empty_hrefless_a -enable_scrollback -cookies -noreferer ~/.lynx_bookmarks.html'
alias ll='ls -lh --color'
alias ls='ls --color'
alias python='python3'
alias ranger='ranger -c'
if [ -f /usr/bin/bsdtar ]; then
  alias tar='bsdtar'
fi
alias tree='tree -N'
alias view='vim -R'
alias youtube-dl='youtube-dl -f webm'
