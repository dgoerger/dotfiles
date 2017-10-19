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
  export HISTSIZE=20736
  export HOSTNAME=$(hostname -s)
  export HTOPRC=/dev/null
  export LC_ALL="en_CA.UTF-8"
  export LESSHISTFILE=-
  export LYNX_CFG=${HOME}/.lynxrc
  #export MUTTRC=${path_to_mutt_gpg}
## randomized colour prompt
#  export PS1="$(printf \\r)$(tput bold)$(tput setaf $(echo ${RANDOM}%8 | /usr/bin/bc))$(hostname -s)$(tput setaf 0)\\>$(tput sgr0) "
  export PS1='$ '
  if [[ -r /usr/local/lib/python3_startup.py ]]; then
    export PYTHONSTARTUP=/usr/local/lib/python3_startup.py
  fi
  export SSH_AUTH_SOCK="${HOME}/.ssh/${USER}.socket"
  export TZ='US/Eastern'
  export VISUAL=vim

  # aliases
  alias bc='bc -l'
  alias cal='cal -m'
  if [[ -x "$(which colordiff)" ]]; then
    alias diff='colordiff'
  fi
  if [[ -x "$(which fetchmail)" ]]; then
    alias fetch='fetchmail --silent'
  fi
  if [[ -x "$(which kpcli)" ]]; then
    alias kpcli='kpcli --histfile=/dev/null --readonly'
  fi
  alias l='ls -lh'
  alias la='ls -lha'
  alias less='less -R'
  alias ll='ls -lh'
  if [[ -x "$(which tree)" ]]; then
    alias tree='tree -a'
  fi
  if [[ -x "$(which vim)" ]]; then
    alias vi=vim
    alias view='vim --cmd "let no_plugin_maps = 1" -c "runtime! macros/less.vim" -m -n'
  fi
  if [[ -x "$(which curl)" ]]; then
    alias weather='curl -4k https://wttr.in/?m'
  fi

  # fixes
  #stty erase '^?' echoe
  set -o emacs
  umask 077
  if [[ "${TERM}" == "screen" ]] || [[ -n "${TMUX}" ]]; then
    # tmux window name
    printf '\033k%s@%s\033\\' "${USER}" "${HOSTNAME}"
  fi
  if [[ ! -S "${SSH_AUTH_SOCK}" ]]; then
    eval $(ssh-agent -s -a ${SSH_AUTH_SOCK} >/dev/null)
  elif ! $(pgrep -U ${USER} ssh-agent >/dev/null); then
    if [[ -S "${SSH_AUTH_SOCK}" ]]; then
      rm "${SSH_AUTH_SOCK}"
      eval $(ssh-agent -s -a ${SSH_AUTH_SOCK} >/dev/null)
    fi
  fi

  # tab completions
  if [[ "$(uname)" == "OpenBSD" ]] && [[ "${SHELL}" == '/bin/ksh' ]]; then
    export PKG_LIST=$(ls -1 /var/db/pkg)
    set -A complete_git_1 -- pull push clone checkout status commit
    set -A complete_gpg2 -- --refresh --receive-keys --armor --clearsign --sign --list-key --decrypt --verify --detach-sig
    set -A complete_ifconfig_1 -- $(ifconfig | grep ^[a-z] | cut -d: -f1)
    set -A complete_kill_1 -- -9 -HUP -INFO -KILL -TERM
    set -A complete_mosh -- $(awk '{split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
    set -A complete_pkg_delete -- $PKG_LIST
    set -A complete_pkg_info -- $PKG_LIST
    set -A complete_rcctl_1 -- disable enable get ls order set
    set -A complete_rcctl_2 -- $(ls /etc/rc.d)
    set -A complete_signify_1 -- -C -G -S -V
    set -A complete_signify_2 -- -q -p -x -c -m -t -z
    set -A complete_signify_3 -- -p -x -c -m -t -z
    set -A complete_ssh -- $(awk '{split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
  fi
fi
