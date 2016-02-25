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
export HTOPRC=-
unset HISTFILE

# set EDITOR
export EDITOR=vim

# user specific aliases and functions
alias grep='grep --color=always -n'
alias l='ls -lh --color'
alias less='less -R'
alias links='links -http.fake-firefox 1 -http.do-not-track 1 -ssl.certificates 2 -smb.allow-hyperlinks-to-smb 0 -save-url-history 0'
alias lynx='lynx -use_mouse -vikeys -nomore -noprint -tna -force_empty_hrefless_a -enable_scrollback -nocolor -cookies'
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

### UPDATE: disabled because it renames whatever window is active which
###         can be weird when running scripts which ssh to hosts in series
## set tmux window name to the server we're sshing to
#if [ "$(ps -p $(ps -p $$ -o ppid=) -o comm=)" = "tmux" ]; then
#  ssh() {
## limitation: this won't find the correct hostname if not connecting to fqdns and also specifying parameters after the hostname!
##             e.g: ssh nonfqdn -D 1080 will give a window name of '1080'
#    host=`echo "$*" | awk -F"." '{print $1}' | awk -F" " '{print $(NF)}'`
#    tmux rename-window "${host}"
#    command ssh "$@"
#    tmux set-option automatic-rename "on" 1>/dev/null
#  }
#fi
