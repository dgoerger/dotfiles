# .bashrc

# source global definitions
if [[ -f /etc/bashrc ]]; then
  . /etc/bashrc
fi

export HTOPRC=/dev/null
export LESSHISTFILE=-
export QUOTING_STYLE=literal
export VISUAL=vim

### set system-wide python3 prefs
if [[ -r /usr/local/share/python3_startup.py ]]; then
  export PYTHONSTARTUP=/usr/local/share/python3_startup.py
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
export PS1="$(printf \\r)$(tput bold)$(tput setaf $(echo ${RANDOM}%8 | /usr/bin/bc))$(hostname -s)$(tput setaf 0)\\>$(tput sgr0) "

# mail
#export MUTTRC=${path_to_mutt_gpg}
