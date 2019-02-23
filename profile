# .profile

### all operating systems and shells
# PATH and PS1
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
export LANG="en_CA.UTF-8"
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
  alias duckduckgo='surfraw duckduckgo'
  alias wikipedia='surfraw wikipedia'
  alias wiktionary='surfraw wiktionary'
fi
export TZ='US/Eastern'
export VISUAL=vi


## aliases
if [[ -x "$(/usr/bin/which 2048 2>/dev/null)" ]]; then
  alias 2048='2048 -c'
fi
if [[ -x "$(/usr/bin/which abook 2>/dev/null)" ]]; then
  alias abook='abook --config ${HOME}/.abookrc --datafile ${HOME}/.addresses'
fi
alias bc='bc -l'
alias cal='cal -m'
if [[ -x "$(/usr/bin/which calendar 2>/dev/null)" ]]; then
  alias calendar='calendar -f ${HOME}/.calendar'
fi
alias cp='cp -i'
if [[ -x "$(/usr/bin/which cvs 2>/dev/null)" ]]; then
  alias cvsup='cvs -q up -PdA'
fi
alias df='df -h'
if [[ -x "$(/usr/bin/which colordiff 2>/dev/null)" ]]; then
  alias diff='colordiff'
fi
if [[ -r "${HOME}/.elynxrc" ]]; then
  alias elynx='COLUMNS=80 lynx -cfg=~/.elynxrc -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0" 2>/dev/null'
fi
if [[ -x "$(/usr/bin/which fetchmail 2>/dev/null)" ]] && [[ -r "${HOME}/.fetchmailrc" ]]; then
  alias fetch='fetchmail --silent'
fi
alias free='top | grep -E "^Memory"'
if [[ -x "$(/usr/bin/which kpcli 2>/dev/null)" ]]; then
  alias kpcli='kpcli --histfile=/dev/null --readonly'
fi
alias l='ls -1F'
alias la='ls -lhFa'
alias larth='ls -larthF'
alias less='less -MR'
alias listening='fstat -n | grep internet'
alias ll='ls -lhF'
alias ls='ls -F'
alias lynx='COLUMNS=80 lynx -useragent "Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0" 2>/dev/null'
alias mv='mv -i'
if [[ -x "$(/usr/bin/which newsboat 2>/dev/null)" ]]; then
  alias news='newsboat -q'
fi
if [[ -x "$(/usr/bin/which python3 2>/dev/null)" ]]; then
  alias py=python3
  alias python=python3
fi
alias rm='rm -i'
if [[ -x "$(/usr/bin/which nvim 2>/dev/null)" ]]; then
  # prefer neovim > vim if available
  alias vi='nvim -u ${HOME}/.vimrc -i NONE'
  alias view='nvim -u ${HOME}/.vimrc -i NONE --cmd "let no_plugin_maps = 1" -c "runtime! macros/less.vim" -m -M -R -n --'
  alias vim='nvim -u ${HOME}/.vimrc -i NONE'
  alias vimdiff='nvim -u ${HOME}/.vimrc -i NONE -d -c "color blue" --'
elif [[ -x "$(/usr/bin/which vim 2>/dev/null)" ]]; then
  alias vi=vim
  alias view='vim --cmd "let no_plugin_maps = 1" -c "runtime! macros/less.vim" -m -M -R -n --'
  alias vimdiff='vim -d -c "color blue" --'
else
  alias view='less -MR'
  alias vim=vi
fi
#if [[ -x "$(/usr/bin/which curl 2>/dev/null)" ]]; then
#  alias weather='curl -4k https://wttr.in/?m'
#fi
alias which='/usr/bin/which'

# kaomoji
alias disapprove='echo '\''ಠ_ಠ'\'''
alias kilroy='echo '\''ฅ^•ﻌ•^ฅ'\'''
alias rage='echo '\''(╯°□°）╯︵ ┻━┻'\'''
alias shrug='echo '\''¯\_(ツ)_/¯'\'''
alias stare='echo '\''(•_•)'\'''
alias sunglasses='echo '\''(■_■¬)'\'''
alias woohoo='echo \\\(ˆ˚ˆ\)/'


## daemons
## gpg-agent
#if ! pgrep -U "${USER}" -f "gpg-agent --daemon --quiet" >/dev/null 2>&1; then
#  # if not running but socket exists, delete
#  if [[ -S "${HOME}/.gnupg/S.gpg-agent" ]]; then
#    /bin/rm "${HOME}/.gnupg/S.gpg-agent"
#  elif [[ -n ${XDG_RUNTIME_DIR} ]] && [[ -S "${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent" ]]; then
#    /bin/rm "${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent"
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
  # create ~/.ssh if missing - some operating systems don't include this in /etc/skel
  if [[ ! -d "${HOME}/.ssh" ]]; then
    mkdir -m 0700 "${HOME}/.ssh"
  fi
  if [[ ! -f "${HOME}/.ssh/known_hosts" ]]; then
    touch "${HOME}/.ssh/known_hosts"
  fi
  # if ssh-agent isn't running OR GNOME Keyring controls the socket
  export SSH_AUTH_SOCK="${HOME}/.ssh/${USER}@${HOSTNAME}.socket"
  if [[ ! -S "${SSH_AUTH_SOCK}" ]]; then
    eval $(ssh-agent -s -a "${SSH_AUTH_SOCK}" >/dev/null)
  elif ! pgrep -U "${USER}" -f "ssh-agent -s -a ${SSH_AUTH_SOCK}" >/dev/null 2>&1; then
    if [[ -S "${SSH_AUTH_SOCK}" ]]; then
      # if proc isn't running but the socket exists, remove and restart
      /bin/rm "${SSH_AUTH_SOCK}"
      eval $(ssh-agent -s -a "${SSH_AUTH_SOCK}" >/dev/null)
    fi
  fi
fi


### OS-specific overrides
if [[ "$(uname)" == "Linux" ]]; then
  # env
  export MANWIDTH=80
  if [[ -L "/bin" ]]; then
    # some Linux have /bin -> /usr/bin
    export PATH=/bin:/sbin
  fi
  export QUOTING_STYLE=literal
  unset LS_COLORS
  if [[ -x "$(/usr/bin/which flatpak 2>/dev/null)" ]]; then
    if [[ "${XDG_DATA_DIRS#*flatpak}" == "${XDG_DATA_DIRS}" ]]; then
      XDG_DATA_DIRS="${XDG_DATA_HOME:-"$HOME/.local/share"}/flatpak/exports/share:/var/lib/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
      export XDG_DATA_DIRS
    fi
  fi

  # aliases
  if [[ -x "$(/usr/bin/which bc 2>/dev/null)" ]]; then
    alias bc='bc -ql'
  fi
  alias df='df -h -xtmpfs -xdevtmpfs'
  alias doas='umask 0022 && /usr/bin/sudo' #mostly-compatible
  alias free='free -h'
  if [[ -x "$(/usr/bin/which tnftp 2>/dev/null)" ]]; then
    # BSD ftp has support for wget-like functionality
    alias ftp=tnftp
  fi
  alias l='ls -1F --color=never'
  alias la='ls -lhFa --color=never'
  # linux doesn't have fstat
  if [[ -x "$(/usr/bin/which netstat 2>/dev/null)" ]]; then
    alias listening='netstat -launt | grep LISTEN'
  else
    alias listening='ss -tuna'
  fi
  alias ll='ls -lhF --color=never'
  alias ls='ls -F --color=never'
  # linux ps lists kernel threads amongst procs.. deselect those
  # .. it's a bit hacky, but seems to work
  # ref: https://unix.stackexchange.com/a/78585
  alias psaux='ps auw --ppid 2 -p 2 --deselect'
  if [[ -x "$(/usr/bin/which sshfs 2>/dev/null)" ]]; then
    alias sshfs='sshfs -o no_readahead,idmap=user'
  fi
  alias sha256='sha256sum --tag'
  alias sha512='sha512sum --tag'
  alias sudo='umask 0022 && /usr/bin/sudo'
  if [[ -x "$(/usr/bin/which tree 2>/dev/null)" ]]; then
    alias tree='tree -N'
  fi
  if [[ -z "$(whence whence 2>/dev/null)" ]]; then
    # whence exists in ksh, but not in bash
    alias whence='(alias; declare -f) | /usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot'
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
    alias checksnaps='/usr/local/bin/lynx "$(cat /etc/installurl)/snapshots/$(uname -m)"'
  fi

  # bind - clear screen with "ctrl+l"
  bind -m '^L'=^Uclear'^J^Y'

  # SIGINFO - see signal(3)
  stty status ^T
fi


# ksh tab completions
if [[ "${0}" == 'ksh' ]] || [[ "${0}" == '-ksh' ]]; then
  export HOST_LIST=$(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts)

  set -A complete_dig_1 -- ${HOST_LIST}
  set -A complete_git_1 -- add bisect blame checkout clone commit diff log mv pull push rebase reset revert rm stash status submodule
  set -A complete_gpg2 -- --refresh --receive-keys --armor --clearsign --sign --list-key --decrypt --verify --detach-sig
  set -A complete_host_1 -- ${HOST_LIST}
  set -A complete_ifconfig_1 -- $(ifconfig | awk -F':' '/^[a-z]/ {print $1}')
  set -A complete_kill_1 -- -9 -HUP -INFO -KILL -TERM
  set -A complete_kpcli_1 -- --kdb
  if [[ "$(uname)" == 'OpenBSD' ]]; then
    set -A complete_man_1 -- $(man -k Nm~. | cut -d\( -f1 | tr -d ,)
  fi
  if pgrep sndio >/dev/null 2>&1; then
    set -A complete_mixerctl_1 -- $(mixerctl | cut -d= -f 1)
    alias voldown='mixerctl outputs.master=-5,-5'
    alias volup='mixerctl outputs.master=+5,+5'
  fi
  if [[ -x "$(/usr/bin/which mosh 2>/dev/null)" ]]; then
    set -A complete_mosh_1 -- -4 -6
    set -A complete_mosh_2 -- ${HOST_LIST}
    set -A complete_mosh_3 -- --
    set -A complete_mosh_4 -- tmux
    set -A complete_mosh_5 -- attach
  fi
  if [[ -x "$(/usr/bin/which mtr 2>/dev/null)" ]]; then
    set -A complete_mtr_1 -- ${HOST_LIST}
  fi
  if [[ -x "$(/usr/bin/which nmap 2>/dev/null)" ]]; then
    set -A complete_nmap_1 -- ${HOST_LIST}
  fi
  set -A complete_openssl_1 -- s_client
  set -A complete_openssl_2 -- -connect
  set -A complete_ping_1 -- ${HOST_LIST}
  set -A complete_ping6_1 -- ${HOST_LIST}
  if [[ "$(uname)" == 'OpenBSD' ]] && [[ -r /etc/rc.d ]]; then
    set -A complete_rcctl_1 -- disable enable get ls order set
    set -A complete_rcctl_2 -- $(rcctl ls all)
  fi
  if [[ -x "$(/usr/bin/which rmapi 2>/dev/null)" ]]; then
    set -A complete_rmapi_1 -- help put version
  fi
  set -A complete_rsync_1 -- -HhLPprStv
  set -A complete_rsync_2 -- ${HOST_LIST}
  set -A complete_rsync_3 -- ${HOST_LIST}
  if [[ -x "$(/usr/bin/which signify 2>/dev/null)" ]]; then
    set -A complete_signify_1 -- -C -G -S -V
    set -A complete_signify_2 -- -q -p -x -c -m -t -z
    set -A complete_signify_3 -- -p -x -c -m -t -z
  fi
  set -A complete_scp_1 -- -4p
  set -A complete_scp_2 -- ${HOST_LIST}
  set -A complete_scp_3 -- ${HOST_LIST}
  set -A complete_sftp_1 -- -4p
  set -A complete_sftp_2 -- ${HOST_LIST}
  set -A complete_sftp_3 -- ${HOST_LIST}
  if [[ -x "$(/usr/bin/which surfraw 2>&1)" ]]; then
    set -A complete_surfraw_1 -- $(/bin/ls /usr/local/lib/surfraw)
    set -A complete_surfraw_2 -- -local-help
  fi
  set -A complete_ssh_1 -- ${HOST_LIST}
  set -A complete_telnet_1 -- ${HOST_LIST}
  set -A complete_telnet_2 -- 22 25 80 443 465 587
  if [[ -x "$(/usr/bin/which toot 2>&1)" ]]; then
    set -A complete_toot_1 -- block curses follow mute post timeline unblock unfollow unmute upload whoami whois
    set -A complete_toot_2 -- --help
  fi
  set -A complete_tmux_1 -- attach list-commands list-sessions list-windows new-session new-window source
  set -A complete_traceroute_1 -- ${HOST_LIST}
  set -A complete_traceroute6_1 -- ${HOST_LIST}
fi


### functions
# apropos()
apropos() {
  if [[ $# -eq 1 ]]; then
    if [[ "$(uname)" == 'Linux' ]]; then
      /usr/bin/man -wK "${1}"
    elif [[ "$(uname)" == 'OpenBSD' ]]; then
      /usr/bin/man -k any="${1}"
    else
      apropos "${1}"
    fi
  else
    echo "Usage: 'apropos WORD'" && return 1
  fi
}

# colours() test for true colour support
colours() {
  awk -v term_cols="${width:-$(tput cols || echo 80)}" 'BEGIN{
    s="/\\";
    for (colnum = 0; colnum<term_cols; colnum++) {
      r = 255-(colnum*255/term_cols);
      g = (colnum*510/term_cols);
      b = (colnum*255/term_cols);
      if (g>255) g = 510-g;
      printf "\033[48;2;%d;%d;%dm", r,g,b;
      printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
      printf "%s\033[0m", substr(s,colnum%2+1,1);
    }
    printf "\n";
  }'
}

# compare512() sha512 file comparison
compare512() {
  if [[ $# == 2 ]] && [[ -r "${1}" ]] && [[ -r "${2}" ]]; then
    file1="$(sha512 ${1} | awk '{print $NF}')"
    file2="$(sha512 ${2} | awk '{print $NF}')"

    if [[ "${file1}" == "${file2}" ]]; then
      echo "The two files are sha512-identical."
    else
      echo "The two files are NOT sha512-identical."
    fi
  else
      echo -e 'Usage: compare FILE1 FILE2\n' && return 1
  fi
}

# def()
if [[ -x "$(/usr/bin/which wn 2>/dev/null)" ]] && [[ -x "$(/usr/bin/which pandoc 2>/dev/null)" ]]; then
  def() {
    if [[ $# -eq 1 ]]; then
      if [[ -n "$(wn ${1} -over)" ]]; then
        wn "${1}" -over | pandoc -t plain -
      elif [[ -x "$(/usr/bin/which wtf 2>/dev/null)" ]]; then
        wtf "${1}"
      else
        echo "No definition found for ${1}."
      fi
    else
      echo "Usage: 'def WORD'" && return 1
    fi
  }
fi

# dvd() and radio()
if [[ -x "$(/usr/bin/which mpv 2>/dev/null)" ]]; then
  audiocd() {
    if [[ "$(uname)" == 'OpenBSD' ]] && [[ ! -r /dev/rcd0c ]]; then
      echo 'Cannot read /dev/rcd0c. Try: chgrp wheel /dev/rcd0c' && return 1
    fi
    if [[ $# -eq 0 ]]; then
      mpv cdda://
    else
      echo "Usage: 'audiocd' (play whole disk) ['audiocd INT' (play track #INT) doesn't work yet]" && return 1
    fi
  }
  dvd() {
    if [[ "$(uname)" == 'OpenBSD' ]] && [[ ! -r /dev/rcd0c ]]; then
      echo 'Cannot read /dev/rcd0c. Try: chgrp wheel /dev/rcd0c' && return 1
    fi
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
        ## via https://www.radio-browser.info
        # SDF.org
        anon) mpv "http://anonradio.net:8000/anonradio" ;;
        # Deutschland: Antenne1 Stuttgart
        antenne1) mpv "http://81.201.157.218/a1stg/livestream2.mp3" ;;
        # United Kingdom: BBC
        bbc1) mpv "http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio1_mf_p" ;;
        bbc2) mpv "http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio2_mf_p" ;;
        bbc3) mpv "http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio3_mf_p" ;;
        bbc4) mpv "http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio4fm_mf_p" ;;
        bbc5) mpv "http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio5live_mf_p" ;;
        bbcworld) mpv "http://as-hls-ww-live.bbcfmt.hs.llnwd.net/pool_27/live/bbc_world_service/bbc_world_service.isml/bbc_world_service-audio%3d96000.norewind.m3u8" ;;
        # Canada: CBC Winnipeg
        cbw) mpv "http://cbc_r1_wpg.akacast.akamaistream.net/7/831/451661/v1/rc.akacast.akamaistream.net/cbc_r1_wpg" ;;
        # Deutschland: FC-Köln
        effzeh) mpv "http://mp3.fckoeln.c.nmdn.net/fckoeln/livestream01.mp3" ;;
        # USA: ESPN
        espn) mpv "http://espn-network.akacast.akamaistream.net/7/245/126490/v1/espn.akacast.akamaistream.net/espn-network" ;;
        # USA: Fox Sports
        foxsports) mpv "http://c5icyelb.prod.playlists.ihrhls.com/5227_icy" ;;
        # Canada: Radio-Canada Montréal (français)
        ici) mpv "http://2QMTL0.akacast.akamaistream.net/7/953/177387/v1/rc.akacast.akamaistream.net/2QMTL0" ;;
        ici-musique) mpv "http://7qmtl0.akacast.akamaistream.net/7/445/177407/v1/rc.akacast.akamaistream.net/7QMTL0" ;;
        # USA: Prairie Public Radio (North Dakota)
        kdsu) mpv "https://18433.live.streamtheworld.com/KCNDHD3_SC" ;;
        # USA: The Fan Sports Radio (North Dakota)
        knfl) mpv "https://18813.live.streamtheworld.com:3690/KVOXAMAAC_SC" ;;
        # USA: Minnesota Public Radio
        mpr) mpv "https://current.stream.publicradio.org/kcmp.mp3" ;;
        # USA: NBC Sports
        nbcsports) mpv "http://icy3.abacast.com/dialglobal-nbcsportsmp3-48" ;;
        # Deutschland: Schwul
        pride1) mpv "http://stream.pride1.de:8000/;stream.mp3" ;;
        queerlive) mpv "https://queerlive.stream.laut.fm/queerlive" ;;
        # Deutschland: Schlager
        schlager) mpv "http://85.25.217.30/schlagerparadies" ;;
        # Deutschland: SWR3
        swr3) mpv "http://swr-swr3-live.cast.addradio.de/swr/swr3/live/mp3/128/stream.mp3" ;;
        # United Kingdom: talkSports
        talksport) mpv "https://radio.talksport.com/stream?awparams=platform:ts-web&amsparams=playerid:ts-web" ;;
        talksport2) mpv "https://radio.talksport.com/stream2?awparams=platform:ts-web&amsparams=playerid:ts-web" ;;
        # USA: NPR WGBH Boston
        wgbh) mpv "http://audio.wgbh.org:8000" ;;
        # USA: NPR WNYC New York City
        wnyc) mpv "http://fm939.wnyc.org/wnycfm" ;;
        # USA: Y94 top hits (Fargo, North Dakota)
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
    elif echo "${1}" | grep -Evq '\.(epub|html|txt)$'; then
      echo -e "${usage}" && return 1
    elif ! ls "${1}" >/dev/null 2>&1; then
      echo 'ERROR: file not found' && return 1
    else
      echo 'Reformatting.. (might take a moment)'
      pandoc -t html "${1}" | lynx -stdin
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
if [[ -x "$(/usr/bin/which tmux 2>/dev/null)" ]]; then
  # GNOME3 - libnotify "toaster" popup
  if [[ -x "$(/usr/bin/which notify-send 2>/dev/null)" ]] && [[ -n "${DESKTOP_SESSION}" ]]; then
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
      tmux new -d "sleep $(echo "${delay}*60" | bc -l); notify-send POMODORO \"${message}\" --icon=dialog-warning-symbolic --urgency=critical"
    }
  # headless!
  elif [[ -x "$(/usr/bin/which leave 2>/dev/null)" ]]; then
    pomodoro() {
      usage='Usage: pomodoro [minutes]\n\n  .. or just use leave(1)!\n'
      if [[ $# -ne 1 ]]; then
        echo -e "${usage}" && return 1
      fi
      case ${1} in
        ''|*[!0-9]*) echo "Error: \${1} must be an integer." && return 1 ;;
        *) delay=${1} ;;
      esac
      leave +${1}
    }
  fi
fi

# pwgen() random password generator
pwgen() {
  if [[ $# == 0 ]]; then
    </dev/urandom tr -cd [:alnum:] | fold -w 30 | head -n1
  elif [[ $# == 1 ]]; then
    case ${1} in
      ''|*[!0-9]*) echo "Error: \${1} must be an integer." && return 1 ;;
      *) </dev/urandom tr -cd [:alnum:] | fold -w ${1} | head -n1
    esac
  else
    echo "Usage: pwgen [INT], where INT defaults to 30." && return 1
  fi
 }


### source profile-local files
set -o emacs
if [[ -r "${HOME}/.profile.local" ]]; then
  . "${HOME}/.profile.local"
fi
