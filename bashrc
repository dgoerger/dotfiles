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

# connect to ssh socket if running under systemd
if [[ -S ${XDG_RUNTIME_DIR}/ssh-agent.socket" ]]; then
  export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
fi

# git user info
export GIT_AUTHOR_NAME="$(getent passwd $LOGNAME | cut -d: -f5 | cut -d, -f1)"
export GIT_AUTHOR_EMAIL="$(getent passwd $LOGNAME | cut -d: -f1)@users.noreply.github.com"
