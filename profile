# .profile

### all operating systems and shells
# PATH
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/games:/usr/local/bin
_ps1() {
  # detect git project name (if any)
  _gitproject="$(git rev-parse --show-toplevel 2>/dev/null | awk -F'/' '{print $NF}')"
  if [[ -r "${PWD}/CVS/Repository" ]]; then
    # fetch cvs project name (if any)
    _cvsproject="$(cat ${PWD}/CVS/Repository 2>/dev/null | awk -F'/' '{print $1}')"
    printf "%s*%s" "${_cvsproject}" "$(hostname -s)"
  elif [[ -n "${_gitproject}" ]]; then
    printf "%s*%s" "${_gitproject}" "$(hostname -s)"
  else
    # else just print the hostname
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
if [[ -r ${HOME}/.pythonrc ]]; then
  export PYTHONSTARTUP=${HOME}/.pythonrc
fi
if [[ -x "$(/usr/bin/which surfraw 2>/dev/null)" ]]; then
  export SURFRAW_text_browser=${BROWSER}
fi
export TZ='US/Eastern'
export VISUAL=vi


## aliases
if [[ -x "$(/usr/bin/which abook 2>/dev/null)" ]]; then
  alias abook='abook --config ${HOME}/.ssh/abookrc --datafile ${HOME}/.ssh/addressbook'
fi
alias bc='bc -l'
alias cal='cal -m'
if [[ -x "$(/usr/bin/which calendar 2>/dev/null)" ]]; then
  export CALENDAR_DIR="${HOME}/.ssh"
fi
alias df='df -h'
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
if [[ -x "$(/usr/bin/which newsboat 2>/dev/null)" ]]; then
  alias news=newsboat
fi
alias psaux='ps aux'
if [[ -x "$(/usr/bin/which python3 2>/dev/null)" ]]; then
  alias py=python3
  alias python=python3
fi
alias ssh-add='ssh-add -c'
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
alias which='/usr/bin/which'

# kaomoji
alias disapprove='echo '\''ಠ_ಠ'\'''
alias kilroy='echo '\''ฅ^•ﻌ•^ฅ'\'''
alias shrug='echo '\''¯\_(ツ)_/¯'\'''
alias stare='echo '\''(•_•)'\'''
alias sunglasses='echo '\''(■_■¬)'\'''
alias table_flip='echo '\''(╯°□°）╯︵ ┻━┻'\'''
alias woohoo='echo \\\(ˆ˚ˆ\)/'


## daemons
## gpg-agent
#if ! pgrep -U "${USER}" -f "gpg-agent --daemon --quiet" >/dev/null 2>&1; then
#  # if not running but socket exists, delete
#  if [[ -S "${HOME}/.gnupg/S.gpg-agent" ]]; then
#    rm "${HOME}/.gnupg/S.gpg-agent"
#  elif [[ -n ${XDG_RUNTIME_DIR} ]] && [[ -S "${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent" ]]; then
#    rm "${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent"
#  fi
#  if [[ -x "$(/usr/bin/which gpg-agent 2>/dev/null)" ]]; then
#    if [[ ! -d "${HOME}/.gnupg" ]]; then
#      mkdir -m0700 -p "${HOME}/.gnupg"
#    fi
#    eval $(gpg-agent --daemon --quiet 2>/dev/null)
#  fi
#fi

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
  if [[ -x "$(/usr/bin/which bc 2>/dev/null)" ]]; then
    alias bc='bc -ql'
  fi
  alias df='df -h -xtmpfs -xdevtmpfs'
  alias doas='/usr/bin/sudo' #mostly-compatible
  alias free='free -h'
  if [[ -x "$(/usr/bin/which tnftp 2>/dev/null)" ]]; then
    # BSD ftp has support for wget-like functionality
    alias ftp=tnftp
  fi
  alias l='ls -lhF --color=auto'
  alias la='ls -lhFa --color=auto'
  # linux doesn't have fstat
  alias listening='ss -ntau'
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
  if [[ -r /etc/installurl ]]; then
    # shortcut to check snapshot availability - especially useful during release/freeze
    alias checksnaps='lynx "$(cat /etc/installurl)/snapshots/$(uname -m)"'
  fi
  alias free='top -d1 | head -n4'

  # bind - clear screen with "ctrl+l"
  bind -m '^L'=^Uclear'^J^Y'

  # tab completions
  set -A complete_dig_1 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
  set -A complete_git_1 -- add bisect blame checkout clone commit diff log mv pull push rebase reset revert rm stash status submodule
  set -A complete_gpg2 -- --refresh --receive-keys --armor --clearsign --sign --list-key --decrypt --verify --detach-sig
  set -A complete_host_1 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
  set -A complete_ifconfig_1 -- $(ifconfig | awk -F':' '/^[a-z]/ {print $1}')
  set -A complete_kill_1 -- -9 -HUP -INFO -KILL -TERM
  set -A complete_kpcli_1 -- --kdb
  set -A complete_man_1 -- $(man -k Nm~. | cut -d\( -f1 | tr -d ,)
  if pgrep sndio >/dev/null 2>&1; then
    set -A complete_mixerctl_1 -- $(mixerctl | cut -d= -f 1)
  fi
  set -A complete_mosh_1 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
  set -A complete_mosh_2 -- --
  set -A complete_mosh_3 -- tmux
  set -A complete_mosh_4 -- attach
  set -A complete_nmap_1 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
  set -A complete_openssl_1 -- s_client
  set -A complete_openssl_2 -- -connect
  set -A complete_ping_1 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
  set -A complete_rcctl_1 -- disable enable get ls order set
  set -A complete_rcctl_2 -- $(rcctl ls all)
  set -A complete_rsync_1 -- -rltHhPv
  set -A complete_rsync_2 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1] ":"}' ~/.ssh/known_hosts)
  set -A complete_rsync_3 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1] ":"}' ~/.ssh/known_hosts)
  set -A complete_signify_1 -- -C -G -S -V
  set -A complete_signify_2 -- -q -p -x -c -m -t -z
  set -A complete_signify_3 -- -p -x -c -m -t -z
  set -A complete_scp_1 -- -4pr
  set -A complete_scp_2 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1] ":"}' ~/.ssh/known_hosts)
  set -A complete_scp_3 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1] ":"}' ~/.ssh/known_hosts)
  if [[ -x "$(/usr/bin/which surfraw 2>&1)" ]]; then
    set -A complete_surfraw_1 -- $(ls /usr/local/lib/surfraw)
    set -A complete_surfraw_2 -- -local-help
  fi
  set -A complete_ssh_1 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
  set -A complete_telnet_1 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
  set -A complete_toot_1 -- block curses follow mute post timeline unblock unfollow unmute upload whoami whois
  set -A complete_toot_2 -- --help
  set -A complete_traceroute_1 -- $(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts)
fi


### functions
# dvd() and radio()
if [[ -x "$(/usr/bin/which mpv 2>/dev/null)" ]]; then
  dvd() {
    if [[ $# -eq 1 ]]; then
      case ${1} in
        ''|*[!0-9]*) echo "Error: \${1} must be an integer." && return 1 ;;
        *) mpv --audio-normalize-downmix=yes dvdread://${1} ;;
      esac
    else
      echo "Usage: 'dvd INT', where INT is the chapter number." && return 1
    fi
  }
  radio() {
    usage='Usage:  radio stream_name\n'
    if [[ $# -eq 1 ]]; then
      case ${1} in
        # via https://www.radio-browser.info
        anon) mpv "http://anonradio.net:8000/anonradio" ;;
        antenne1) mpv "http://81.201.157.218/a1stg/livestream2.mp3" ;;
        bbc1) mpv "http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio1_mf_p" ;;
        bbc2) mpv "http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio2_mf_p" ;;
        bbc3) mpv "http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio3_mf_p" ;;
        bbc4) mpv "http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio4fm_mf_p" ;;
        bbc5) mpv "http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio5live_mf_p" ;;
        bbcworld) mpv "http://as-hls-ww-live.bbcfmt.hs.llnwd.net/pool_27/live/bbc_world_service/bbc_world_service.isml/bbc_world_service-audio%3d96000.norewind.m3u8" ;;
        cbw) mpv "http://cbc_r1_wpg.akacast.akamaistream.net/7/831/451661/v1/rc.akacast.akamaistream.net/cbc_r1_wpg" ;;
        fc) mpv "http://mp3.fckoeln.c.nmdn.net/fckoeln/livestream01.mp3" ;;
        ici) mpv "http://2QMTL0.akacast.akamaistream.net/7/953/177387/v1/rc.akacast.akamaistream.net/2QMTL0" ;;
        ici-musique) mpv "http://7qmtl0.akacast.akamaistream.net/7/445/177407/v1/rc.akacast.akamaistream.net/7QMTL0" ;;
        kdsu) mpv "https://18433.live.streamtheworld.com/KCNDHD3_SC" ;;
        mpr) mpv "https://current.stream.publicradio.org/kcmp.mp3" ;;
        schlager) mpv "http://85.25.217.30/schlagerparadies" ;;
        swr3) mpv "http://swr-swr3-live.cast.addradio.de/swr/swr3/live/mp3/128/stream.mp3" ;;
        wgbh) mpv "http://audio.wgbh.org:8000" ;;
        wnyc) mpv "http://fm939.wnyc.org/wnycfm" ;;
        y94) mpv "https://16693.live.streamtheworld.com/KOYYFMAAC_SC" ;;
        *) echo -e "Error: unknown stream" && return 1 ;;
      esac
    else
      echo -e "${usage}" && return 1
    fi
  }
fi

# ereader()
if [[ -x "$(/usr/bin/which pandoc 2>/dev/null)" ]] && [[ -x "$(/usr/bin/which lynx 2>/dev/null)" ]]; then
  ereader() {
    usage='Usage: ereader file.epub\n'
    if [[ $# -ne 1 ]]; then
      echo -e "${usage}" && return 1
    elif [[ "${1}" = '-h' ]] || [[ "${1}" = '--help' ]]; then
      echo -e "${usage}" && return 0
    elif echo "${1}" | grep -Evq '\.epub$'; then
      echo -e "${usage}" && return 1
    elif ! ls "${1}" >/dev/null 2>&1; then
      echo 'ERROR: file not found' && return 1
    else
      echo 'Reformatting.. (might take a moment)'
      pandoc -f epub -t html "${1}" | lynx -stdin
    fi
  }
fi

# photo_import()
if [[ -x "$(which exiv2 2>/dev/null)" ]]; then
  _import_photo() {
    DATETIME="$(exiv2 -pt -qK Exif.Photo.DateTimeOriginal "${1}" 2>/dev/null | awk '{print $(NF-1)}' | sed 's/\:/\//g' | sort -u)"
    FILENAME="$(echo "${1}" | awk -F"/" '{print $NF}' | tr '[:upper:]' '[:lower:]')"
    PHOTO_DIR="${HOME}/Pictures"

    # sanity checks
    if [[ -z "${DATETIME}" ]]; then
      echo "${1}: Abort! DateTime not found" && return 1
    elif [[ "$(echo "${DATETIME}" | wc -l)" -ne 1 ]]; then
      echo "${1}: Abort! File has more than one DateTime declaration" && return 1
    elif [[ "$(uname)" == 'OpenBSD' ]]; then
      if ! date -j "$(echo "${DATETIME}/0000" | sed 's/\///g')" >/dev/null 2>&1; then
        echo "${1}: Abort! /bin/date doesn't recognise the detected DateTime as a valid date" && return 1
      fi
    elif [[ "$(uname)" == 'Linux' ]]; then
      if ! date --date="$(echo "${DATETIME}" | sed 's/\///g')" >/dev/null 2>&1; then
        echo "${1}: Abort! /bin/date doesn't recognise the detected DateTime as a valid date" && return 1
      fi
    fi

    # copy the file into place
    if [[ -n "${FILENAME}" ]]; then
      mkdir -p "${PHOTO_DIR}/${DATETIME}"
      if [[ ! -f "${PHOTO_DIR}/${DATETIME}/${FILENAME}" ]]; then
        cp -p "${1}" "${PHOTO_DIR}/${DATETIME}/${FILENAME}"
      fi
    fi
  }
  photo_import() {
    # This script will search recursively for exif metadata in supported
    #   files within the current directory, and copy images to
    #   $PHOTO_DIR/$YYYY/$MM/$DD
    FILETYPES="jpg jpeg"
    for x in ${FILETYPES}; do
      find . -type f -iname "*.${x}" | while read -r photo; do _import_photo "${photo}"; done
    done
  }
fi

# pomodoro()
if [[ -x "$(/usr/bin/which notify-send 2>/dev/null)" ]] && [[ -x "$(/usr/bin/which tmux 2>/dev/null)" ]] && [[ -n "${DESKTOP_SESSION}" ]]; then
  pomodoro() {
    usage='Usage: pomodoro [minutes] [message]\n'
    if [[ $# -ne 2 ]]; then
      echo -e "${usage}" && return 1
    else
      message="${2}"
    fi
    case ${1} in
      ''|*[!0-9]*) echo "Error: \${1} must be an integer." && return 1 ;;
      *) delay=${1} ;;
    esac
    tmux new -d "sleep $(echo "${delay}*60" | bc -l); notify-send POMODORO ${message} --icon=dialog-warning-symbolic --urgency=critical"
  }
fi


### source profile-local files
set -o emacs
if [[ -r "${HOME}/.profile.local" ]]; then
  . "${HOME}/.profile.local"
fi
