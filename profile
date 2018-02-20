# .profile

### PATH
if [[ "$(uname)" == 'Linux' ]]; then
  export PATH=/usr/local/bin:/usr/bin:/usr/sbin
  if [[ ! -L /bin ]]; then
    export PATH=${PATH}:/bin:/sbin
  fi
elif [[ "$(uname)" == 'NetBSD' ]]; then
  export PATH=/usr/pkg/bin:/usr/bin:/bin:/usr/local/bin:/usr/pkg/games
elif [[ "$(uname)" == 'OpenBSD' ]]; then
  export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/games:/usr/local/bin
fi

### all operating systems and shells
# detect git branch (if any)
_ps1() {
  _gitbr="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  _gitproject="$(git rev-parse --show-toplevel 2>/dev/null | awk -F'/' '{print $NF}')"
  if [ -n "${_gitbr}" ] && [ -n "${_gitproject}" ]; then
    if [ "${_gitbr}" = 'master' ]; then
      # alert with RED when operating on `master`
      printf "[\033[1;34m%s\033[m@\033[1;31m%s\033[m]" "${_gitproject}" "${_gitbr}"
    else
      # else print branch name in GREEN
      printf "[\033[1;34m%s\033[m@\033[1;32m%s\033[m]" "${_gitproject}" "${_gitbr}"
    fi
  else
    # else print hostname
    printf "%s" "$(hostname -s)"
  fi
}

# terminal settings
#stty erase '^?' echoe
umask 077


## environment variables
export BROWSER=lynx
export GIT_AUTHOR_EMAIL="$(getent passwd ${LOGNAME} | cut -d: -f1)@users.noreply.github.com"
export GIT_AUTHOR_NAME="$(getent passwd ${LOGNAME} | cut -d: -f5 | cut -d, -f1)"
export GIT_COMMITTER_EMAIL=${GIT_AUTHOR_EMAIL}
export GIT_COMMITTER_NAME=${GIT_AUTHOR_NAME}
#export GITHUB_HOST=if.not.github.com #for `hub`
#export GITHUB_TOKEN= #for `hub`
export GITHUB_USER="${USER}"
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
export PS1='$(_ps1)$ '
if [[ -r /usr/local/lib/python3_startup.py ]]; then
  export PYTHONSTARTUP=/usr/local/lib/python3_startup.py
fi
if [[ -x "$(/usr/bin/which surfraw 2>/dev/null)" ]]; then
  export SURFRAW_text_browser=${BROWSER}
fi
export TZ='US/Eastern'
if [[ -x "$(/usr/bin/which mg 2>/dev/null)" ]]; then
  export VISUAL=mg
else
  export VISUAL=vi
fi


## aliases
alias bc='bc -l'
alias cal='cal -m'
if [[ -x "$(/usr/bin/which colordiff 2>/dev/null)" ]]; then
  alias diff='colordiff'
fi
if [[ -x "$(/usr/bin/which fetchmail 2>/dev/null)" ]] && [[ -r "${HOME}/.fetchmailrc" ]]; then
  alias fetch='fetchmail --silent'
fi
if [[ -x "$(/usr/bin/which kpcli 2>/dev/null)" ]]; then
  alias kpcli='kpcli --histfile=/dev/null --readonly'
fi
alias l='ls -lhF'
alias la='ls -lhFa'
alias less='less -MR'
alias listening='fstat -n | grep internet'
alias ll='ls -lhF'
alias psaux='ps aux'
if [[ -x "$(/usr/bin/which nvim 2>/dev/null)" ]]; then
  # prefer neovim > vim if available
  alias vi='nvim -u ${HOME}/.vimrc -i NONE'
  alias view='nvim -u ${HOME}/.vimrc -i NONE --cmd "let no_plugin_maps = 1" -c "runtime! macros/less.vim" -m -M -R -n'
  alias vim='nvim -u ${HOME}/.vimrc -i NONE'
elif [[ -x "$(/usr/bin/which vim 2>/dev/null)" ]]; then
  alias vi=vim
  alias view='vim --cmd "let no_plugin_maps = 1" -c "runtime! macros/less.vim" -m -M -R -n'
else
  alias view='less -MR'
  alias vim=vi
fi
if [[ -x "$(/usr/bin/which curl 2>/dev/null)" ]]; then
  alias weather='curl -4k https://wttr.in/?m'
fi

# emoji
alias disapprove='echo '\''ಠ_ಠ'\'''
alias shrug='echo '\''¯\_(ツ)_/¯'\'''
alias table_flip='echo '\''(╯°□°）╯︵ ┻━┻'\'''
alias woohoo='echo \\\(ˆ˚ˆ\)/'


## daemons
# gpg-agent
if ! pgrep -U "${USER}" -f "gpg-agent --daemon --quiet" >/dev/null 2>&1; then
  # if not running but socket exists, delete
  if [[ -S "${HOME}/.gnupg/S.gpg-agent" ]]; then
    rm "${HOME}/.gnupg/S.gpg-agent"
  elif [[ -S "${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent" ]]; then
    rm "${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent"
  elif [[ ! -d "${HOME}/.gnupg" ]]; then
    mkdir -m0700 -p "${HOME}/.gnupg"
  fi
  if [[ -x "$(/usr/bin/which gpg-agent 2>/dev/null)" ]]; then
    eval $(gpg-agent --daemon --quiet 2>/dev/null)
  fi
fi

# ssh-agent
if [[ -z ${SSH_AUTH_SOCK} ]] || [[ -n $(echo ${SSH_AUTH_SOCK} | grep -E "^/run/user/$(id -u)/keyring/ssh$") ]]; then
  # if ssh-agent isn't running OR GNOME Keyring controls the socket
  export SSH_AUTH_SOCK="${HOME}/.ssh/${USER}@${HOSTNAME}.socket"
  if [[ ! -S "${SSH_AUTH_SOCK}" ]]; then
    eval $(ssh-agent -s -a "${SSH_AUTH_SOCK}" >/dev/null)
  elif ! pgrep -U "${USER}" -f "ssh-agent -s -a ${SSH_AUTH_SOCK}" >/dev/null 2>&1; then
    if [[ -S "${SSH_AUTH_SOCK}" ]]; then
      # if proc isn't running but the socket exists, remove and restart
      rm "${SSH_AUTH_SOCK}"
      eval $(ssh-agent -s -a "${SSH_AUTH_SOCK}" >/dev/null)
    fi
  fi
fi


### OS-specific overrides
if [[ "$(uname)" == "Linux" ]]; then
  # env
  export QUOTING_STYLE=literal
  unset LS_COLORS

  # aliases
  alias doas='/usr/bin/sudo' #mostly-compatible
  if [[ -x "$(/usr/bin/which tnftp 2>/dev/null)" ]]; then
    # BSD ftp has support for wget-like functionality
    alias ftp=tnftp
  else
    alias ftp='curl -LO'
  fi
  alias l='ls -lhF --color=auto'
  alias la='ls -lhFa --color=auto'
  # linux doesn't have fstat, but does have a pretty good netstat
  alias listening='netstat -launt'
  alias ll='ls -lhF --color=auto'
  alias ls='ls -F --color=auto'
  # linux ps lists kernel threads amongst procs.. deselect those
  # .. it's a bit hacky, but seems to work 4.15.x (F27)
  # ref: https://unix.stackexchange.com/a/78585
  alias psaux='ps au --ppid 2 -p 2 --deselect'
  if [[ -x "$(/usr/bin/which tree 2>/dev/null)" ]]; then
    alias tree='tree -N'
  fi
elif [[ "$(uname)" == 'OpenBSD' ]]; then
  # aliases
  if [[ -x "$(which cabal 2>/dev/null)" ]] && [[ -d /usr/local/cabal/build ]] && [[ -w /usr/local/cabal/build ]]; then
    # ref: https://deftly.net/posts/2017-10-12-using-cabal-on-openbsd.html
    ln -sf /usr/local/cabal ${HOME}/.cabal
    alias cabal='env TMPDIR=/usr/local/cabal/build/ cabal'
    # alias the pandoc relocatable-binary build command for easy reference
    alias pandoc_rebuild='cabal update && cabal install pandoc -fembed_data_files -fhttps'
  fi

  # tab completions
  set -A complete_dig_1 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
  set -A complete_git_1 -- add bisect blame checkout clone commit diff log mv pull push rebase reset revert rm stash status submodule
  set -A complete_gpg2 -- --refresh --receive-keys --armor --clearsign --sign --list-key --decrypt --verify --detach-sig
  set -A complete_host_1 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
  set -A complete_ifconfig_1 -- $(ifconfig | awk -F':' '/^[a-z]/ {print $1}')
  set -A complete_kill_1 -- -9 -HUP -INFO -KILL -TERM
  set -A complete_kpcli_1 -- --kdb
  set -A complete_man_1 -- $(ls /usr/share/man/man{1,2,3,4,5,6,7,8,9}/ /usr/local/man/man{1,2,3,3f,3p,4,5,6,7,8,9}/ | grep -Ev "(^|:)$" | awk -F'\.' '/[A-Z].*[A-Z]/i {print $1}' | sort -u)
  if pgrep sndio >/dev/null 2>&1; then
    set -A complete_mixerctl_1 -- $(mixerctl | cut -d= -f 1)
  fi
  set -A complete_mosh_1 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
  set -A complete_mosh_2 -- --
  set -A complete_mosh_3 -- tmux
  set -A complete_mosh_4 -- attach
  set -A complete_nmap_1 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
  set -A complete_ping_1 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
  set -A complete_rcctl_1 -- disable enable get ls order set
  set -A complete_rcctl_2 -- $(ls /etc/rc.d)
  set -A complete_rsync_1 -- -rltHhPv
  set -A complete_rsync_2 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1] ":"}' ~/.ssh/known_hosts)
  set -A complete_rsync_3 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1] ":"}' ~/.ssh/known_hosts)
  set -A complete_signify_1 -- -C -G -S -V
  set -A complete_signify_2 -- -q -p -x -c -m -t -z
  set -A complete_signify_3 -- -p -x -c -m -t -z
  set -A complete_scp_1 -- -3 -4 -6 -p -r
  set -A complete_scp_2 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1] ":"}' ~/.ssh/known_hosts)
  set -A complete_scp_3 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1] ":"}' ~/.ssh/known_hosts)
  set -A complete_surfraw_1 -- $(ls /usr/local/lib/surfraw)
  set -A complete_surfraw_2 -- -local-help
  set -A complete_ssh_1 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
  set -A complete_telnet_1 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
  set -A complete_toot_1 -- block curses follow mute post timeline unblock unfollow unmute upload whoami whois
  set -A complete_toot_2 -- --help
  set -A complete_traceroute_1 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
fi


### source profile-local files
set -o emacs
if [[ -r "${HOME}/.profile.local" ]]; then
  . "${HOME}/.profile.local"
fi
