# .profile

### all operating systems and shells
## prelude
# source system files first in case we override things here
if [[ "${SHELL}" == "/bin/bash" ]] && [[ -r /etc/bashrc ]]; then
  . /etc/bashrc
fi

# terminal settings
#stty erase '^?' echoe
umask 077


## environment variables
export GIT_AUTHOR_EMAIL="$(getent passwd $LOGNAME | cut -d: -f1)@users.noreply.github.com"
export GIT_AUTHOR_NAME="$(getent passwd $LOGNAME | cut -d: -f5 | cut -d, -f1)"
export GIT_COMMITTER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_COMMITTER_NAME=$GIT_AUTHOR_NAME
export HISTCONTROL=ignoredups
export HISTFILE=${HOME}/.history
export HISTSIZE=20736
export HOSTNAME=$(hostname -s)
export HTOPRC=/dev/null
export LC_ALL="en_CA.UTF-8"
export LESSSECURE=1
export LESSHISTFILE=-
export LYNX_CFG=${HOME}/.lynxrc
#export MUTTRC=${path_to_mutt_gpg}
export PS1='$ '
if [[ -r /usr/local/lib/python3_startup.py ]]; then
  export PYTHONSTARTUP=/usr/local/lib/python3_startup.py
fi
export TZ='US/Eastern'
export VISUAL=vim


## aliases
alias bc='bc -l'
alias cal='cal -m'
if [[ -x "$(which colordiff 2>/dev/null)" ]]; then
  alias diff='colordiff'
fi
if [[ -x "$(which fetchmail 2>/dev/null)" ]]; then
  alias fetch='fetchmail --silent'
fi
if [[ -x "$(which kpcli 2>/dev/null)" ]]; then
  alias kpcli='kpcli --histfile=/dev/null --readonly'
fi
alias l='ls -lh'
alias la='ls -lha'
alias less='less -R'
alias listening='netstat -an | less'
alias ll='ls -lh'
if [[ -x "$(which vim 2>/dev/null)" ]]; then
  alias vi=vim
  alias view='vim --cmd "let no_plugin_maps = 1" -c "runtime! macros/less.vim" -m -n'
fi
if [[ -x "$(which curl 2>/dev/null)" ]]; then
  alias weather='curl -4k https://wttr.in/?m'
fi

# emoji
alias disapprove='echo '\''ಠ_ಠ'\'''
alias shrug='echo '\''¯\_(ツ)_/¯'\'''
alias table_flip='echo '\''(╯°□°）╯︵ ┻━┻'\'''


## daemons
if [[ "$(uname)" != 'NetBSD' ]]; then
  # pgrep coredumps on sdf.org..?

  # gpg-agent
  if [[ -z "$(pgrep -U ${USER} gpg-agent)" ]]; then
    # if not running but socket exists, delete
    if [[ -S "${HOME}/.gnupg/S.gpg-agent" ]]; then
      rm "${HOME}/.gnupg/S.gpg-agent"
    elif [[ -S "${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent" ]]; then
      rm "${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent"
    elif [[ ! -d "${HOME}/.gnupg" ]]; then
      mkdir -m0700 -p "${HOME}/.gnupg"
    fi
    if [[ -x "$(which gpg-agent 2>/dev/null)" ]]; then
      eval $(gpg-agent --daemon --quiet 2>/dev/null)
    fi
  fi

  # ssh-agent
  if [[ -z ${SSH_AUTH_SOCK} ]] || [[ -n $(echo ${SSH_AUTH_SOCK} | grep -E "^/run/user/$(id -u)/keyring/ssh$") ]]; then
    # if ssh-agent isn't running OR GNOME Keyring controls the socket
    export SSH_AUTH_SOCK="${HOME}/.ssh/${USER}.socket"
    if [[ ! -S "${SSH_AUTH_SOCK}" ]]; then
      eval $(ssh-agent -s -a ${SSH_AUTH_SOCK} >/dev/null)
    elif ! $(pgrep -U ${USER} ssh-agent >/dev/null); then
      if [[ -S "${SSH_AUTH_SOCK}" ]]; then
        # if proc isn't running but the socket exists, remove and restart
        rm "${SSH_AUTH_SOCK}"
        eval $(ssh-agent -s -a ${SSH_AUTH_SOCK} >/dev/null)
      fi
    fi
  fi
fi

# tmux
if [[ "${TERM}" == "screen" ]] || [[ -n "${TMUX}" ]]; then
  # set tmux window name
  printf '\033k%s@%s\033\\' "${USER}" "${HOSTNAME}"
fi


### specifics
## Linux
if [[ "$(uname)" == "Linux" ]]; then
  # env
  export QUOTING_STYLE=literal
  unset LS_COLORS

  # aliases
  alias l='ls -lh --color=auto'
  alias la='ls -lha --color=auto'
  alias ll='ls -lh --color=auto'
  alias ls='ls --color=auto'
  if [[ -x "$(which --skip-alias tree 2>/dev/null)" ]]; then
    alias tree='tree -N'
  fi
fi

## NetBSD
if [[ "$(uname)" == "NetBSD" ]]; then
  # env
  PAGER=less

  # aliases
  cal='cal -europe -nocolor'
fi

## OpenBSD
if [[ "$(uname)" == "OpenBSD" ]] && [[ "${SHELL}" == '/bin/ksh' ]]; then
  # aliases
  if [[ -x "$(which cabal 2>/dev/null)" ]] && [[ -d /usr/local/cabal/build ]] && [[ -w /usr/local/cabal/build ]]; then
    # ref: https://deftly.net/posts/2017-10-12-using-cabal-on-openbsd.html
    alias cabal='env TMPDIR=/usr/local/cabal/build/ cabal'
  fi

  # tab completions
  export PKG_LIST=$(ls -1 /var/db/pkg)
  set -A complete_git_1 -- add bisect blame checkout clone commit diff log mv pull push rebase reset revert rm stash status submodule
  set -A complete_gpg2 -- --refresh --receive-keys --armor --clearsign --sign --list-key --decrypt --verify --detach-sig
  set -A complete_ifconfig_1 -- $(ifconfig | grep "^[a-z]" | cut -d: -f1)
  set -A complete_kill_1 -- -9 -HUP -INFO -KILL -TERM
  set -A complete_mosh_1 -- $(awk '{split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
  set -A complete_mosh_2 -- --
  set -A complete_mosh_3 -- tmux
  set -A complete_mosh_4 -- attach
  set -A complete_pkg_delete -- ${PKG_LIST}
  set -A complete_pkg_info -- ${PKG_LIST}
  set -A complete_rcctl_1 -- disable enable get ls order set
  set -A complete_rcctl_2 -- $(ls /etc/rc.d)
  set -A complete_rsync_2 -- $(awk '{split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
  set -A complete_rsync_3 -- $(awk '{split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
  set -A complete_signify_1 -- -C -G -S -V
  set -A complete_signify_2 -- -q -p -x -c -m -t -z
  set -A complete_signify_3 -- -p -x -c -m -t -z
  set -A complete_scp_1 -- $(awk '{split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
  set -A complete_ssh_1 -- $(awk '{split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
fi

### source profile-local files
set -o emacs
if [[ -r "${HOME}/.profile.local" ]]; then
  . ${HOME}/.profile.local
fi
