# .profile

if [[ "${SHELL}" == "/bin/bash" ]]; then
  # source env and aliases
  if [[ -f ${HOME}/.bashrc ]]; then
    . ${HOME}/.bashrc
  elif [[ -f /etc/bashrc ]]; then
    . /etc/bashrc
  fi
else
  # env
  export GIT_AUTHOR_EMAIL="$(getent passwd $LOGNAME | cut -d: -f1)@users.noreply.github.com"
  export GIT_AUTHOR_NAME="$(getent passwd $LOGNAME | cut -d: -f5 | cut -d, -f1)"
  export GIT_COMMITTER_EMAIL=$GIT_AUTHOR_EMAIL
  export GIT_COMMITTER_NAME=$GIT_AUTHOR_NAME
  export HISTFILE=${HOME}/.history
  export HISTSIZE=1728
  export HOSTNAME=$(hostname -s)
  export HTOPRC=/dev/null
  export LC_ALL="en_CA.UTF-8"
  export LESSHISTFILE=-
  export LYNX_CFG=${HOME}/.lynxrc
  #export MUTTRC=${path_to_mutt_gpg}
## randomized colour prompt
#  export PS1="$(printf \\r)$(tput bold)$(tput setaf $(echo ${RANDOM}%8 | /usr/bin/bc))$(hostname -s)$(tput setaf 0)\\>$(tput sgr0) "
  export PS1='$ '
  #export TZ='US/Eastern'
  export VISUAL=vim

  # aliases
  alias bc='bc -l'
  alias cal='cal -m'
  alias l='ls -lh'
  alias la='ls -lha'
  alias less='less -R'
  alias ll='ls -lh'
  alias tree='tree -a'
  alias vi=vim
  alias view='vim --cmd "let no_plugin_maps = 1" -c "runtime! macros/less.vim" -m -n'
  alias weather='curl -4k https://wttr.in/?m'

  # fixes
  #stty erase '^?' echoe
  set -o emacs
  umask 077
  if [[ "${TERM}" == "screen-256color" ]] || [[ -n "${TMUX}" ]]; then
    # tmux window name
    printf '\033k%s@%s\033\\' "${USER}" "${HOSTNAME}"
  fi
fi
