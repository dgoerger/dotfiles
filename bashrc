# .bashrc

# source global definitions
if [[ -f /etc/bashrc ]]; then
  source /etc/bashrc
fi

# connect to ssh socket if running under systemd
if [[ -S ${XDG_RUNTIME_DIR}/ssh-agent.socket ]]; then
  export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
fi

# git user info
export GIT_AUTHOR_EMAIL="$(getent passwd $LOGNAME | cut -d: -f1)@users.noreply.github.com"
export GIT_AUTHOR_NAME="$(getent passwd $LOGNAME | cut -d: -f5 | cut -d, -f1)"
export GIT_COMMITTER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITTER_NAME=$GIT_AUTHOR_NAME

# colourize prompt
export PS1='\[\e[1;32m\]\h\[\e[0m\]\[\e[1;30m\]\\\>\[\e[0m\] '

# set window title - not on NetBSD and older RHEL by default
#export PROMPT_COMMAND='printf "\033k%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'

# fix backspace - not necessary on most systems
#stty erase '^?' echoe

# mail
#export MUTTRC=${path_to_mutt_gpg}
