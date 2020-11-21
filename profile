# ~/.profile

### all operating systems and shells
## PATH
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/games:/usr/local/bin

# quick exit for non-interactive shells
if [[ ${-} != *i* ]]; then return; fi

## terminal settings
# fix backspace on old TERMs
#stty erase '^?' echoe
# disable terminal flow control (ctrl+s/ctrl+q)
stty -ixon
# disable job control (^Z)
set +m
# SIGINFO: see signal(3)
stty status ^T 2>/dev/null
# restrict umask (override in ~/.profile.local)
umask 077


## environment variables
unset ENV
export BROWSER=lynx
export EDITOR=vi
export GIT_AUTHOR_EMAIL="${LOGNAME}@users.noreply.github.com"
export GIT_AUTHOR_NAME="$(getent passwd "${LOGNAME}" | cut -d: -f5 | cut -d, -f1)"
export HISTCONTROL=ignoredups
export HISTFILE=${HOME}/.history
export HISTSIZE=20736
export HOSTNAME=$(hostname -s)
export LANG="en_CA.UTF-8"
export LC_ALL="en_CA.UTF-8"
export LESSSECURE=1
export LESSHISTFILE=-
if [[ -r "${HOME}/.lynxrc" ]]; then
	if [[ -r "${HOME}/.elynxrc" ]]; then
		alias elynx='COLUMNS=80 lynx -cfg=~/.elynxrc -useragent "Mozilla/5.0 (Windows NT 10.0; rv:68.0) Gecko/20100101 Firefox/68.0" 2>/dev/null'
	fi
	export LYNX_CFG="${HOME}/.lynxrc"
	alias lynx='COLUMNS=80 lynx -useragent "Mozilla/5.0 (Windows NT 10.0; rv:68.0) Gecko/20100101 Firefox/68.0" 2>/dev/null'
fi
if [[ -r "${HOME}/.pythonrc" ]]; then
	export PYTHONSTARTUP="${HOME}/.pythonrc"
fi
export SAVEHIST=${HISTSIZE}
export TZ='America/New_York'
export VISUAL=${EDITOR}


## aliases
if command -v abook >/dev/null && [[ -r "${HOME}/.abookrc" ]] && [[ -r "${HOME}/.addresses" ]]; then
	alias abook='abook --config ${HOME}/.abookrc --datafile ${HOME}/.addresses'
fi
alias bc='bc -l'
if command -v cabal >/dev/null && [[ -d /usr/local/cabal/build ]] && [[ -w /usr/local/cabal/build ]]; then
	alias cabal='env TMPDIR=/usr/local/cabal/build/ cabal'
fi
alias cal='cal -m'
if command -v calendar >/dev/null && [[ -r "${HOME}/.calendar" ]]; then
	alias calendar='calendar -f ${HOME}/.calendar'
fi
alias cp='cp -i'
if command -v cvs >/dev/null; then
	alias cvsup='cvs -q up -PdA'
fi
alias df='df -h'
alias dush='du -had1 | sort -hr'
alias fetch='ftp -Vo'
alias free='top | grep -E "^Memory"'
if command -v grep >/dev/null; then
	alias ggrep='git grep -in --'
fi
if command -v kpcli >/dev/null; then
	alias kpcli='kpcli --histfile=/dev/null --readonly --kdb'
fi
alias l='ls -1F'
alias la='ls -aFhl'
alias larth='ls -aFhlrt'
alias less='less -iLMR'
alias listening='netstat -lnp tcp && netstat -lnp udp'
alias ll='ls -Fhl'
alias ls='ls -F'
if command -v mutt >/dev/null; then
	alias mail=mutt
fi
alias mtop='top -o res'
alias mv='mv -i'
if command -v newsboat >/dev/null; then
	alias news='newsboat -q'
fi
alias pscpu='ps -Awwro user,pid,ppid,nice,%cpu,%mem,vsz,rss,state,wchan,time,comm'
alias psmem='ps -Awwmo pid,state,time,pagein,vsz,rss,tsiz,%cpu,%mem,comm'
alias pssec='ps -Awwo pid,state,user,etime,rtable,comm,pledge'
if command -v python3 >/dev/null; then
	alias py=python3
fi
alias realpath='readlink -f'
alias rgrep='grep -rIns --'
alias rm='rm -i'
if ! command -v rsync >/dev/null && command -v openrsync >/dev/null; then
	alias rsync="$(command -v openrsync)"
fi
alias sha512='sha512 -q'
alias stat='stat -x'
alias tm='tmux new-session -A -s tm'
alias view='less -iLMR'
alias w='w -i'
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
# ssh-agent
if [[ -z "${SSH_AUTH_SOCK}" ]] || [[ -n "$(echo "${SSH_AUTH_SOCK}" | grep -E "^/run/user/$(id -u)/keyring/ssh$")" ]] || [[ -n "$(echo "${SSH_AUTH_SOCK}" | grep -E "^/private/tmp/com.apple.launchd.*/Listeners$")" ]]; then
	if [[ -w "${HOME}/.ssh" ]]; then
		# create ~/.ssh if missing - some operating systems don't include this in /etc/skel
		if [[ ! -d "${HOME}/.ssh" ]]; then
			mkdir -m 0700 "${HOME}/.ssh"
		fi
		if [[ ! -f "${HOME}/.ssh/known_hosts" ]]; then
			touch "${HOME}/.ssh/known_hosts"
		fi
		# if ssh-agent isn't running OR GNOME Keyring controls the socket
		export SSH_AUTH_SOCK="${HOME}/.ssh/${LOGNAME}@${HOSTNAME}.socket"
		if [[ ! -S "${SSH_AUTH_SOCK}" ]]; then
			eval $(ssh-agent -s -a "${SSH_AUTH_SOCK}" >/dev/null)
		elif ! pgrep -U "${LOGNAME}" -f "ssh-agent -s -a ${SSH_AUTH_SOCK}" >/dev/null 2>&1; then
			if [[ -S "${SSH_AUTH_SOCK}" ]]; then
				# if proc isn't running but the socket exists, remove and restart
				/bin/rm "${SSH_AUTH_SOCK}"
				eval $(ssh-agent -s -a "${SSH_AUTH_SOCK}" >/dev/null)
			fi
		fi
	fi
fi


### OS-specific overrides
if [[ "$(uname)" == 'Darwin' ]]; then
	# zsh tab completion
	autoload -Uz compinit
	compinit -i -D

	export MANWIDTH=80

	alias bc='bc -ql'
	alias cal='/usr/bin/ncal -C'
	alias dns_reset='sudo killall -HUP mDNSResponder; sudo killall mDNSResponderHelper; sudo dscacheutil -flushcache'
	alias dush='du -hd1 | sort -hr'
	alias fetch='curl -Lso'
	alias free='top -l 1 -s 0 | grep PhysMem'
	getent() {
		# implement just enough of getent(1) so that user functions work
		if [[ "${#}" == '2' ]] && [[ "${1}" == 'hosts' ]]; then
			host "${2}" | grep -qE "has( IPv6 | )address"
			return $?
		fi
	}
	alias ldd='otool -L'
	alias listening='netstat -an | grep LISTEN'
	alias mtop='top -o mem'
	alias pssec='ps -Awo pid,state,user,etime,comm'
	alias realpath='readlink'
	unalias sha512
	function sha512 {
		shasum -a 512 "${1}" | awk '{print $1}'
	}

elif [[ "$(uname)" == 'FreeBSD' ]]; then
	alias cal='/usr/bin/ncal -C'
	alias dush='du -hd1 | sort -hr'
	alias free='top | grep -E "^Mem"'
	alias pssec='ps -Awo pid,state,user,etime,comm,jail'

elif [[ "$(uname)" == 'Linux' ]]; then
	# env
	export HTOPRC=/dev/null
	export MANWIDTH=80
	if [[ -L "/bin" ]]; then
		# some Linux have /bin -> /usr/bin
		export PATH=/usr/local/bin:/bin:/sbin
	fi
	if [[ -d "${HOME}/bin" ]]; then
		export PATH=${HOME}/bin:${PATH}
	fi
	export QUOTING_STYLE=literal
	unset LS_COLORS

	# aliases
	function apropos {
		# man(1) default search order: 1,8,3,2,5,4,9,6,7
		man -s 1,8,5,4,6,7 -wK "${@}" | awk -F'(/|\\.)' '{system("/usr/bin/whatis " $(NF-2))}'
	}
	if command -v atop >/dev/null; then
		alias atop='atop -f'
	fi
	alias bc='bc -ql'
	if [[ -r /etc/alpine-release ]]; then
		alias checkupdates='apk list -u'
	elif [[ -r /etc/debian_version ]]; then
		if [[ -x /usr/bin/ncal ]]; then
			alias cal='/usr/bin/ncal -bM'
		fi
		alias checkupdates='apt list --upgradeable'
	elif [[ -r /etc/redhat-release ]]; then
		alias checkupdates='yum -q check-update'
	fi
	alias doas=/usr/bin/sudo #mostly-compatible
	alias fetch='curl -Lso'
	alias free='free -h'
	alias l='LC_ALL=C ls -1F --color=never'
	alias la='LC_ALL=C ls -aFhl --color=never'
	alias larth='LC_ALL=C ls -aFhlrt --color=never'
	alias listening='ss -lntu'
	alias ll='LC_ALL=C ls -Fhl --color=never'
	alias ls='LC_ALL=C ls -F --color=never'
	alias man='man --nh --nj'
	alias mtop='top -s -o "RES"'
	alias pscpu='ps -Awwo user,pid,ppid,nice,pcpu,pmem,vsz:10,rss:8,stat,cputime,comm --sort -pcpu,-vsz,-pmem,-rss'
	alias psmem='ps -Awwo pid,stat,cputime,majflt,vsz:10,rss:8,trs:8,pcpu,pmem,comm --sort -vsz,-rss,-pcpu'
	alias pssec='ps -Awo pid,stat,user,etime,comm,cgname'
	alias realpath='readlink -ev'
	if command -v sar >/dev/null; then
		alias sarcpu='sar -qu'
		alias sarmem='sar -BHrS'
		alias sarnet='sar -n DEV'
		alias sarnfs='sar -n NFS'
	fi
	unalias sha512
	function sha512 {
		sha512sum --tag "${1}" | awk '{print $NF}'
	}
	unalias stat
	alias top='top -s'
	if [[ -z "$(whence whence 2>/dev/null)" ]]; then
		# whence exists in ksh and zsh, but not in bash
		alias whence='command -v'
	fi
	function zless {
		local flags=
		while test $# -ne 0; do
			case "$1" in
				--)
					shift
					break
					;;
				-*|+*)
					flags="${flags} ${1}"
					shift
					;;
				*)
					break
					;;
			esac
		done

		if [[ $# -eq 0 ]]; then
			gzip -cdf 2>&1 | less "${flags}"
			exit 0
		fi

		oterm=$(stty -g 2>/dev/null)
		while test $# -ne 0; do
			gzip -cdf "$1" 2>&1 | less "${flags}"
			prev="${1}"
			shift
			if tty -s && test -n "${oterm}" -a $# -gt 0; then
				echo -n "$prev (END) - Next: $1 "
				trap "stty ${oterm} 2>/dev/null" 0 1 2 3 13 15
				stty cbreak -echo 2>/dev/null
				REPLY=$(dd bs=1 count=1 2>/dev/null)
				stty ${oterm} 2>/dev/null
				trap - 0 1 2 3 13 15
				echo
				case "$REPLY" in
					s) shift ;;
					e|q) break ;;
				esac
			fi
		done
	}

elif [[ "$(uname)" == 'NetBSD' ]]; then
	export HTOPRC=/dev/null
	export MANPATH=/usr/share/man:/usr/local/man
	if [[ -d "${HOME}/bin" ]]; then
		export PATH=${HOME}/bin:/usr/bin:/bin
	fi
	export PS1="${HOSTNAME}$ "

	alias apropos='/usr/bin/apropos -l'
	alias cal='/usr/bin/cal -d1'
	alias listening='netstat -anf inet | grep -Ev "(ESTABLISHED|TIME_WAIT|FIN_WAIT_1|FIN_WAIT_2)$"'
	alias pkgsrc='ftp -Vo - "https://ftp.netbsd.org/pub/pkgsrc/packages/NetBSD/x86_64/$(uname -r)/All/" 2>/dev/null | less'
	alias pssec='ps -Awo pid,state,user,etime,comm'
	alias realpath='readlink -fv'
	unalias sha512
	function sha512 {
		cksum -a SHA512 "${1}" | awk '{print $NF}'
	}
	alias sysctl=/sbin/sysctl

elif [[ "$(uname)" == 'OpenBSD' ]]; then
	# aliases
	apropos() {
		# search all sections of the manual by default
		/usr/bin/man -k any="${1}"
	}
	if [[ -r /etc/installurl ]]; then
		if [[ -z "$(sysctl kern.version | grep -E "\-(current|beta)")" ]]; then
			checkupdates() {
				# on -stable, check if there are available syspatches
				local _patchfile="$(mktemp /tmp/checkupdates.XXXXXXXXXX)"
				ftp -VMo "${_patchfile}" "$(cat /etc/installurl)/syspatch/$(uname -r)/$(uname -m)/SHA256"
				if [[ "$(echo "(syspatch$(/bin/ls -hrt /var/syspatch/ | tail -n 1).tgz)")" != "$(awk '!/^$/ {print $2}' "${_patchfile}" | tail -n 1)" ]]; then
					printf "%s\n" "Updates are available via syspatch(8)."
				else
					printf "%s\n" "System is up-to-date."
				fi
				/bin/rm "${_patchfile}"
			}
		else
			checkupdates() {
				# on -current, check if there's a newer snap available
				local _snapfile="$(mktemp /tmp/checkupdates.XXXXXXXXXX)"
				local _snapdate="$(mktemp /tmp/checkupdates.XXXXXXXXXX)"
				ftp -VMo "${_snapfile}" "$(cat /etc/installurl)/snapshots/$(uname -m)/SHA256"
				ftp -VMo "${_snapdate}" "$(cat /etc/installurl)/snapshots/$(uname -m)/BUILDINFO"
				if [[ "$(sha512 -q "${_snapfile}")" != "$(sha512 -q /var/db/installed.SHA256)" ]]; then
					printf "%s\n\n" "Updates are available via sysupgrade(8)."
					if [[ "$(file -b "${_snapdate}")" == 'ASCII text' ]]; then
						printf "%s%s\n" "Running: " "$(TZ='Canada/Mountain' date -z 'Canada/Mountain' -jf "%a %b %e %H:%M:%S %Y" "$(sysctl -n kern.version | head -n 1 | awk -F': ' '{print $NF}' | sed 's/MST//' | sed 's/MDT//')" +"%Y%m%d %H:%M:%S")"
						printf "%s%s\n" "Upgrade: " "$(TZ=UTC date -z 'Canada/Mountain' -jf "%a %b %e %H:%M:%S %Z %Y" "$(awk -F ' - ' '{print $NF}' "${_snapdate}")" +"%Y%m%d %H:%M:%S")"
					fi
				else
					printf "%s\n" "System is up-to-date."
				fi
				/bin/rm "${_snapfile}"
				/bin/rm "${_snapdate}"
			}
		fi
	fi
fi


# ksh tab completions
if [[ "${0}" == '-ksh' ]] || [[ "${0}" == 'ksh' ]]; then
	export HOST_LIST=$(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts | sort -u)

	set -A complete_diff_1 -- -u
	set -A complete_dig_1 -- ${HOST_LIST}
	set -A complete_git_1 -- add bisect blame checkout clone commit diff log mv pull push rebase reset revert rm stash status submodule
	set -A complete_host_1 -- ${HOST_LIST}
	if command -v ifconfig >/dev/null; then
		set -A complete_ifconfig_1 -- $(ifconfig | awk -F':' '/^[a-z]/ {print $1}')
	fi
	set -A complete_kill_1 -- -9 -HUP -INFO -KILL -TERM
	if [[ -r /usr/local/etc/manuals.list ]]; then
		set -A complete_man_1 -- $(cat /usr/local/etc/manuals.list)
	fi
	set -A complete_nc_1 -- -c -cv -cvTprotocols=tlsv1.3 -v ${HOST_LIST}
	if command -v ncdu >/dev/null; then
		set -A complete_ncdu_1 -- -rx -x
	fi
	set -A complete_ping_1 -- ${HOST_LIST}
	set -A complete_ping6_1 -- ${HOST_LIST}
	if [[ "$(uname)" == 'OpenBSD' ]] && [[ -r /etc/rc.d ]]; then
		set -A complete_rcctl_1 -- disable enable get ls order set
		set -A complete_rcctl_2 -- $(rcctl ls all)
	fi
	if command -v rmapi >/dev/null; then
		set -A complete_rmapi_1 -- help put version
	fi
	#set -A complete_rsync_1 -- -HhLPSprtv
	set -A complete_scp_1 -- ${HOST_LIST}
	set -A complete_scp_2 -- ${HOST_LIST}
	set -A complete_sftp_1 -- -p
	set -A complete_sftp_2 -- ${HOST_LIST}
	set -A complete_search_1 -- alpine arxiv centos cve debian fedora mandebian mandragonflybsd manfreebsd manillumos manlinux mannetbsd manopenbsd mbug nws rfc rhbz thesaurus wikipedia wiktionary
	set -A complete_ssh_1 -- ${HOST_LIST}
	set -A complete_systat_1 -- buckets cpu ifstat iostat malloc mbufs netstat nfsclient nfsserver pf pigs pool pcache queues rules sensors states swap vmstat uvm
	if command -v toot >/dev/null; then
		set -A complete_toot_1 -- block follow instance mute notifications post tui unblock unfollow unmute upload whoami whois
		set -A complete_toot_2 -- --help
	fi
	set -A complete_tmux_1 -- attach list-commands list-sessions list-windows new-session new-window source
	set -A complete_traceroute_1 -- ${HOST_LIST}
	set -A complete_traceroute6_1 -- ${HOST_LIST}
fi


### functions
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

# def() look up the definition of a word
if command -v curl >/dev/null; then
	def() {
		if [[ $# -eq 2 ]]; then
			if [[ "${1}" == 'cz' ]]; then
				shift
				curl "dict://dict.org/d:${1}:fd-ces-eng"
			elif [[ "${1}" == 'de' ]]; then
				shift
				curl "dict://dict.org/d:${1}:fd-deu-eng"
			elif [[ "${1}" == 'es' ]]; then
				shift
				curl "dict://dict.org/d:${1}:fd-spa-eng"
			elif [[ "${1}" == 'fr' ]]; then
				shift
				curl "dict://dict.org/d:${1}:fd-fra-eng"
			elif [[ "${1}" == 'hu' ]]; then
				shift
				curl "dict://dict.org/d:${1}:fd-hun-eng"
			elif [[ "${1}" == 'it' ]]; then
				shift
				curl "dict://dict.org/d:${1}:fd-ita-eng"
			elif [[ "${1}" == 'nl' ]]; then
				shift
				curl "dict://dict.org/d:${1}:fd-nld-eng"
			elif [[ "${1}" == 'pl' ]]; then
				shift
				curl "dict://dict.org/d:${1}:fd-pol-eng"
			elif [[ "${1}" == 'pt' ]]; then
				shift
				curl "dict://dict.org/d:${1}:fd-por-eng"
			elif [[ "${1}" == 'se' ]]; then
				shift
				curl "dict://dict.org/d:${1}:fd-swe-eng"
			else
				printf "language code not recognised\n"
				return 1
			fi
		elif [[ $# -eq 1 ]]; then
			curl "dict://dict.org/d:${1}:gcide"
		else
			printf "usage:\n    def WORD\n" && return 1
		fi
	}
fi

# diff() with syntax highlighting
diff() {
	# nota bene: [[ -t 1 ]] => "is output to stdout", for example, versus a pipe or a file
	if [[ -t 1 ]] && [[ "${#}" -eq 2 ]] && [[ -r "${1}" ]] && [[ -r "${2}" ]]; then
		/usr/bin/diff "${1}" "${2}" | awk '/^[1-9]/ {printf "\033[0;96m%s\033[0;0m\n", $0}
			/^</ {printf "\033[0;91m%s\033[0;0m\n", $0}
			/^>/ {printf "\033[0;92m%s\033[0;0m\n", $0}
			/^-/ {printf "\033[0;0m%s\n", $0}'
	elif [[ -t 1 ]] && [[ "${#}" -eq 3 ]] && [[ "${1}" == '-u' ]] && [[ -r "${2}" ]] && [[ -r "${3}" ]]; then
		/usr/bin/diff -u "${2}" "${3}" | awk '/^\@/ {printf "\033[0;96m%s\033[0;0m\n", $0}
			/^\-/ {printf "\033[0;91m%s\033[0;0m\n", $0}
			/^\+/ {printf "\033[0;92m%s\033[0;0m\n", $0}
			/^\ / {printf "\033[0;0m%s\033[0;0m\n", $0}'
	else
		/usr/bin/diff "$@"
	fi
}

# ereader()
if command -v pandoc >/dev/null && command -v lynx >/dev/null; then
	ereader() {
		if [[ $# -ne 1 ]]; then
			printf 'usage:\n    ereader file.epub\n' && return 1
		elif [[ "${1}" = '-h' ]] || [[ "${1}" = '--help' ]]; then
			printf 'usage:\n    ereader file.epub\n' && return 0
		elif ! ls "${1}" >/dev/null 2>&1; then
			printf 'ERROR: file not found\n' && return 1
		else
			printf 'Reformatting.. (this might take a moment)\n'
			pandoc -t html "${1}" | lynx -stdin
		fi
	}
fi

# fat32san() sanitize file/folder names for FAT32 filesystems
fat32san() {
	# illegal chars =>   : " ? < > | \ / *
	# FIXME: this strategy isn't safe for removing '/' from a filename
	#        as it's the path directory separator, so do not handle
	#        that char for now
	_rename() {
		mv "${1}" "$(echo "${1}" | tr -d '\:\"\?\<\>\|\\\*')"
	}
	if [[ "${#}" != '1' ]] || [[ ! -d "${1}" ]]; then
		printf "usage:\n    fat32san /path/to/sanitize\n"
	else
		find "${1}" -name '*\:*' | while read -r FILE; do _rename "${FILE}"; done
		find "${1}" -name '*\"*' | while read -r FILE; do _rename "${FILE}"; done
		find "${1}" -name '*\?*' | while read -r FILE; do _rename "${FILE}"; done
		find "${1}" -name '*\<*' | while read -r FILE; do _rename "${FILE}"; done
		find "${1}" -name '*\>*' | while read -r FILE; do _rename "${FILE}"; done
		find "${1}" -name '*\|*' | while read -r FILE; do _rename "${FILE}"; done
		find "${1}" -name '*\\*' | while read -r FILE; do _rename "${FILE}"; done
		find "${1}" -name '*\**' | while read -r FILE; do _rename "${FILE}"; done
	fi
}

# fd() find files and directories
fd() {
	if [[ "${#}" != '1' ]]; then
		printf "usage:\n    fd FILENAME\n"
	else
		find . -iname "*${1}*"
	fi
}

# photo_import() import photos from an SD card
if command -v exiv2 >/dev/null; then
	_import_photo() {
		local DATETIME="$(exiv2 -pt -qK Exif.Photo.DateTimeOriginal "${1}" 2>/dev/null | awk '{print $(NF-1)}' | sed 's/\:/\//g' | sort -u)"
		local FILENAME="$(echo "${1}" | awk -F"/" '{print $NF}' | tr '[:upper:]' '[:lower:]')"
		local PHOTO_DIR="${HOME}/Pictures"

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
		local FILETYPES="jpg jpeg"
		for x in ${FILETYPES}; do
			find . -type f -iname "*.${x}" | while read -r photo; do _import_photo "${photo}"; done
		done
	}
fi

# pomodoro() timer
if command -v tmux >/dev/null; then
	# GNOME3 - libnotify "toaster" popup
	if command -v notify-send >/dev/null && [[ -n "${DESKTOP_SESSION}" ]]; then
		pomodoro() {
			local usage='usage: pomodoro [minutes] [message]\n'
			if [[ $# -ne 2 ]]; then
				echo -e "${usage}" && return 1
			else
				local message="${2}"
			fi
			case ${1} in
				''|*[!0-9]*) echo "Error: \${1} must be an integer." && return 1 ;;
				*) local delay=${1} ;;
			esac
			tmux new -d "sleep $(echo "${delay}*60" | bc -l); notify-send POMODORO \"${message}\" --icon=dialog-warning-symbolic --urgency=critical"
		}
	# headless!
	elif command -v leave >/dev/null; then
		pomodoro() {
			local usage='usage: pomodoro [minutes]\n\n  .. or just use leave(1)!\n'
			if [[ $# -ne 1 ]]; then
				echo -e "${usage}" && return 1
			fi
			case ${1} in
				''|*[!0-9]*) echo "Error: \${1} must be an integer." && return 1 ;;
				*) local delay=${1} ;;
			esac
			leave "+${1}"
		}
	fi
fi

# pwgen() random password generator
pwgen() {
	if [[ $# == 0 ]]; then
		</dev/urandom LC_ALL=C tr -cd '[:alnum:]' | fold -w 30 | head -n1
	elif [[ $# == 1 ]]; then
		case ${1} in
			''|*[!0-9]*) echo "Error: \${1} must be an integer." && return 1 ;;
			*) </dev/urandom LC_ALL=C tr -cd '[:alnum:]' | fold -w "${1}" | head -n1
		esac
	else
		printf "usage:\n    pwgen [INT]\n" && return 1
	fi
}

# rename() files
rename() {
	# options handling, if any
	if [[ "${#}" == '0' ]] || [[ "${1}" == '-h' ]]; then
		printf "usage:\n    rename [-nv] "REGEX" filename(s)\n" && return 0
	elif [[ "${1}" == '-n' ]]; then
		if [[ $# -gt 1 ]]; then
			local noop=1
			shift
		else
			printf "usage:\n    rename [-nv] "REGEX" filename(s)\n" && return 1
		fi
	elif [[ "${1}" == '-v' ]]; then
		if [[ $# -gt 1 ]]; then
			local verbose=1
			shift
		else
			printf "usage:\n    rename [-nv] "REGEX" filename(s)\n" && return 1
		fi
	elif [[ "${1}" == '-nv' ]] || [[ "${1}" == '-vn' ]]; then
		if [[ $# -gt 1 ]]; then
			local noop=1
			local verbose=1
			shift
		else
			printf "usage:\n    rename [-nv] "REGEX" filename(s)\n" && return 1
		fi
	elif [[ "${1}" == '-V' ]]; then
		printf "rename() ksh function defined in ~/.profile\n" && return 0
	fi

	# verify the passed regex is recognised by sed(1)
	if echo test_string | sed -E "${1}" >/dev/null 2>&1; then
		local regex="${1}"
		shift
	else
		printf "ERROR: sed(1) doesn't recognise extended regex '%s'.\n" "${1}" && return 1
	fi

	# verify input file(s) exist
	if [[ -z "${@}" ]]; then
		printf "usage:\n    rename [-nv] "REGEX" filename(s)\n" && return 1
	fi
	if ! /bin/ls "${@}" >/dev/null 2>&1; then
		printf "ERROR: unable to stat file(s) '%s'.\n" "${@}" && return 1
	fi

	# batch rename
	/bin/ls -- "${@}" | while read -r oldname; do
		local newname="$(echo "${oldname}" | sed -E "${regex}")"

		# sanity checks
		if echo "${oldname}" | grep -q '/'; then
			printf "WARNING: source file contains directory path character '/', skipping '%s'\n" "${oldname}"
			continue
		elif echo "${newname}" | grep -q '/'; then
			printf "WARNING: destination file contains directory path character '/', skipping '%s'\n" "${newname}"
			continue
		elif [[ "${newname}" == "${oldname}" ]]; then
			continue
		elif [[ -r "${newname}" ]]; then
			printf "WARNING: destination file '%s' already exists, skipping.\n" "${newname}"
			continue
		fi

		# perform the rename
		if [[ "${noop}" == '1' ]] && [[ "${verbose}" == '1' ]]; then
			printf "%s -> %s\n" "${oldname}" "${newname}"
		elif [[ "${noop}" == '1' ]]; then
			continue
		elif [[ "${verbose}" == '1' ]]; then
			/bin/mv -v -- "${oldname}" "${newname}"
		else
			/bin/mv -- "${oldname}" "${newname}"
		fi
	done
}

# scp() reimplementation based on sftp(1)
scp() {
	if [[ $# == 1 ]]; then
		if [[ "${1}" == '-h' ]]; then
			printf "usage:\n"
			printf "    scp REMOTE:SOURCE\n"
			printf "    scp REMOTE:SOURCE LOCAL_DESTINATION\n"
			printf "    scp LOCAL_SOURCE REMOTE:DESTINATION\n"
			return 0
		elif [[ "${1}" == '-V' ]]; then
			printf "scp() reimplementation based on sftp(1)\n"
			return 0
		else
			# simple fetch
			sftp -p "${1}"
			return $?
		fi
	elif [[ $# == 2 ]]; then
		if printf "%s" "${1}" | grep -q '@'; then
			local arg1_domain_test="$(printf "%s" "${1}" | awk -F'@' '{print $2}' | awk -F':' '{print $1}')"
		else
			local arg1_domain_test="$(printf "%s" "${1}" | awk -F':' '{print $1}')"
		fi
		if printf "%s" "${2}" | grep -q '@'; then
			if printf "%s" "${2}" | grep -q ':'; then
				local arg2_domain_test="$(printf "%s" "${2}" | awk -F'@' '{print $2}' | awk -F':' '{print $1}')"
			else
				local arg2_domain_test="$(printf "%s" "${2}" | awk -F'@' '{print $2}')"
			fi
		else
			if printf "%s" "${2}" | grep -q ':'; then
				local arg2_domain_test="$(printf "%s" "${2}" | awk -F':' '{print $1}')"
			else
				local arg2_domain_test="${2}"
			fi
		fi
		if [[ ! -r "${1}" ]] && [[ -n "${arg1_domain_test}" ]]; then
			if getent hosts "${arg1_domain_test}" >/dev/null 2>&1; then
				local REMOTE="${1}"
			else
				printf "ssh: Could not resolve hostname %s: no address associated with name" "${arg1_domain_test}"
				return 1
			fi
			if [[ -r "${2}" ]] && [[ "${2}" != '.' ]]; then
				printf "scp: destination file already exists, refusing to overwrite\n"
				return 1
			else
				local LOCAL_FILE="${2}"
			fi
			# simple fetch
			sftp -p "${REMOTE}" "${LOCAL_FILE}"
			return $?
		elif [[ ! -r "${2}" ]]; then
			if getent hosts "${2}" >/dev/null 2>&1; then
				local REMOTE="${2}"
				local REMOTE_DEST="."
			elif getent hosts "${arg2_domain_test}" >/dev/null 2>&1; then
				local REMOTE="${arg2_domain_test}"
				local REMOTE_DEST="$(printf "%s" "${2}" | awk -F':' '{print $2}')"
			else
				printf "ssh: Could not resolve hostname %s: no address associated with name" "${arg1_domain_test}"
				return 1
			fi
			if [[ -r "${1}" ]]; then
				local LOCAL_FILE="${1}"
			else
				printf "scp: source file not found\n"
				return 1
			fi
			# simple put
			printf "put %s %s" "${LOCAL_FILE}" "${REMOTE_DEST}" | sftp -p "${REMOTE}"
			return $?
		else
			printf "scp: incorrect syntax\n\n"
		fi
	fi
	printf "usage:\n"
	printf "    scp REMOTE:SOURCE\n"
	printf "    scp REMOTE:SOURCE LOCAL_DESTINATION\n"
	printf "    scp LOCAL_SOURCE REMOTE:DESTINATION\n"
	return 1
}

# search() the web
search() {
	# try to guess preferred language from $LANG
	if [[ -n "${LANG}" ]]; then
		local lang="$(echo "${LANG}" | cut -c1-2)"
	else
		local lang='en'
	fi

	# escape characters for URL-encoding
	_escape_html() {
		echo "$@" | sed 's/%/%25/g;
			s/+/%2B/g;
			s/ /%20/g;
			s/(/%28/g;
			s/)/%29/g;
			s/"/%22/g;
			s/#/%23/g;
			s/\$/%24/g;
			s/&/%26/g;
			s/,/%2C/g;
			sx/x%2Fxg;
			s/:/%3A/g;
			s/;/%3B/g;
			s/</%3C/g;
			s/=/%3D/g;
			s/>/%3E/g;
			s/?/%3F/g;
			s/@/%40/g;
			s/\[/%5B/g;
			s/\\/%5C/g;
			s/\]/%5D/g;
			s/\^/%5E/g;
			s/{/%7B/g;
			s/|/%7C/g;
			s/}/%7D/g;
			s/~/%7E/g;
			s/`/%60/g;
		'"s/'/%27/g"
	}

	# surf the netz raw
	if [[ "${1}" == 'alpine' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://pkgs.alpinelinux.org/packages"
		else
			lynx "https://pkgs.alpinelinux.org/packages?name=${query}&branch=edge"
		fi
	elif [[ "${1}" == 'arxiv' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://arxiv.org/"
		else
			lynx "https://arxiv.org/search/?query=${query}&searchtype=all&source=header"
		fi
	elif [[ "${1}" == 'centos' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://koji.mbox.centos.org/koji/"
		else
			lynx "https://koji.mbox.centos.org/koji/search?match=glob&type=package&terms=${query}"
		fi
	elif [[ "${1}" == 'cve' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "http://cve.mitre.org"
		else
			lynx "http://cve.mitre.org/cgi-bin/cvename.cgi?name=${query}"
		fi
	elif [[ "${1}" == 'debian' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://tracker.debian.org/"
		else
			lynx "https://tracker.debian.org/search?package_name=${query}"
		fi
	elif [[ "${1}" == 'fedora' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://koji.fedoraproject.org/koji"
		else
			lynx "https://koji.fedoraproject.org/koji/search?match=glob&type=package&terms=${query}"
		fi
	elif [[ "${1}" == 'gutenberg' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://www.gutenberg.org/"
		else
			lynx "https://www.gutenberg.org/catalog/world/results?&title=${query}"
		fi
	elif [[ "${1}" == 'mandebian' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://manpages.debian.org/"
		else
			lynx "https://manpages.debian.org/jump?q=${query}"
		fi
	elif [[ "${1}" == 'mandragonflybsd' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://man.dragonflybsd.org/"
		else
			lynx "https://man.dragonflybsd.org/?section=ANY&command=${query}"
		fi
	elif [[ "${1}" == 'manfreebsd' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://www.freebsd.org/cgi/man.cgi"
		else
			lynx "https://www.freebsd.org/cgi/man.cgi?sektion=0&manpath=FreeBSD%2012.1-RELEASE&arch=default&format=ascii&query=${query}"
		fi
	elif [[ "${1}" == 'manillumos' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://illumos.org/man"
		else
			lynx "https://illumos.org/man/${query}"
		fi
	elif [[ "${1}" == 'manlinux' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://www.mankier.com/"
		else
			lynx "https://www.mankier.com/?q=${query}"
		fi
	elif [[ "${1}" == 'mannetbsd' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			# unofficial
			lynx "https://netbsd.gw.com/cgi-bin/man-cgi"
		else
			lynx "https://netbsd.gw.com/cgi-bin/man-cgi?${query}++NetBSD-current"
		fi
	elif [[ "${1}" == 'manopenbsd' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://man.openbsd.org/"
		else
			lynx "https://man.openbsd.org/?sec=0&arch=default&manpath=OpenBSD-current&query=${query}"
		fi
	elif [[ "${1}" == 'mbug' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://bugzilla.mozilla.org/"
		else
			lynx "https://bugzilla.mozilla.org/buglist.cgi?quicksearch=${query}"
		fi
	elif [[ "${1}" == 'nws' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://www.weather.gov/"
		else
			lynx "https://forecast.weather.gov/zipcity.php?inputstring=${query}&btnSearch=Go&unit=1"
		fi
	elif [[ "${1}" == 'rfc' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://www.ietf.org/standards/rfcs/"
		else
			lynx "https://tools.ietf.org/rfc/rfc${query}.txt"
		fi
	elif [[ "${1}" == 'rhbz' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://bugzilla.redhat.com/"
		else
			lynx "https://bugzilla.redhat.com/buglist.cgi?quicksearch=${query}"
		fi
	elif [[ "${1}" == 'thesaurus' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://en.oxforddictionaries.com/english-thesaurus"
		else
			lynx "https://en.oxforddictionaries.com/thesaurus/${query}"
		fi
	elif [[ "${1}" == 'wikipedia' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://${lang}.wikipedia.org/wiki/"
		else
			lynx "https://${lang}.wikipedia.org/wiki/index.php?search=${query}&go=Go"
		fi
	elif [[ "${1}" == 'wiktionary' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://${lang}.wiktionary.org/wiki/"
		else
			lynx "https://${lang}.wiktionary.org/wiki/index.php?search=${query}&go=Go"
		fi
	else
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://www.duckduckgo.com/lite/"
		else
			lynx "https://www.duckduckgo.com/lite/?q=${query}&?kae=t&kac=-1&kaj=m&kam=osm&kak=-1&kax=-1&kv=-1&kaq=-1&kap=-1&kg=g"
		fi
	fi
}

# shacompare() file comparison
shacompare() {
	if [[ $# == 2 ]] && [[ -r "${1}" ]] && [[ -r "${2}" ]]; then
		if cmp -s "${1}" "${2}"; then
			printf 'The two files are identical.\n'
		else
			printf 'The two files are NOT identical.\n'
		fi
	else
		printf 'usage:\n    shacompare FILE1 FILE2\n' && return 1
	fi
}

# sysinfo() system profiler
sysinfo() {
	if [[ "$(uname)" == 'Darwin' ]]; then
		local cpu="$(echo "$(sysctl -n hw.logicalcpu)"cpu: "$(sysctl -n machdep.cpu.brand_string)")"
		local disk_query="$(df -H /System/Volumes/Data 2>/dev/null | tail -n1 | awk '{print $2, $3, $5}')"
		local distro='macOS'
		local gpu="$(system_profiler SPDisplaysDataType | awk -F': ' '/^\ *Chipset Model:/ {print $2}' | awk '{ printf "%s / ", $0 }' | sed -e 's/\/ $//g')"
		local host="$(sysctl -n hw.model)"
		local kernel="$(uname -rm)"
		local memory_query="$(echo "$(echo "$(sysctl -n hw.memsize)" | bc) $(vm_stat | grep ' active' | awk '{ print $3*4*1024 }')")"
	elif [[ "$(uname)" == 'FreeBSD' ]]; then
		local cpu_speed="$(sysctl -n hw.clockrate)"
		local cpu="$(echo "$(sysctl -n hw.ncpu)"cpu: "${cpu_speed:0:1}.${cpu_speed:1}GHz")"
		local disk_query="$(/bin/df -chl | awk '/^total/ {print $2, $3, $4}' | tail -n1)"
		local distro='FreeBSD'
		local gpu="$(pciconf -lv | grep -B 4 -F "VGA" | grep -F "device" | awk -F"'" '{print $2}')"
		local host="$(sysctl -n hw.model)"
		local kernel="$(uname -mr)"
		local memory_query="$(echo "$(sysctl -n hw.pagesize) $(sysctl -n hw.usermem) $(vmstat -s | awk '/pages active$/ {print $1}')" | awk '{ print $2, $1 * $3 }')"
	elif [[ "$(uname)" == 'Linux' ]]; then
		local cpu="$(echo "$(lscpu | awk '/^CPU\(s\):/ {print $NF}')"cpu: "$(grep '^model name' /proc/cpuinfo | uniq | awk -F': ' '{print $NF}' | tr -s " ")")"
		local disk_query="$(/bin/df -h -x aufs -x tmpfs -x overlay -x devtmpfs -x udf -x nfs -x cifs --total 2>/dev/null | awk '{print $2, $3, $5}' | tail -n1)"
		local distro="$(grep PRETTY_NAME /etc/os-release 2>/dev/null | awk -F'"' '{print $2}')"
		if [[ -z "${distro}" ]]; then
			local distro="$(uname -sm)"
		fi
		local gpu="$(lspci -mm | awk -F '\"|\" \"|\\(' '/"Display|"3D|"VGA/ {print $3, $4}' | awk -F'[' '{$1=""; print $0}' | sed 's/\]//g' | sed 's/^\ //g')"
		local host="$(echo "$(cat /sys/devices/virtual/dmi/id/sys_vendor) $(cat /sys/devices/virtual/dmi/id/product_name)")"
		local kernel="$(echo "$(uname -m): $(uname -r | awk -F'-' '{print $1}')" | sed 's/x86_64/amd64/')"
		local memory_query="$(/usr/bin/free -b | grep -E "^Mem:" | awk '{ print $2,$3 }')"
	elif [[ "$(uname)" == 'NetBSD' ]]; then
		local cpu="$(echo "$(sysctl -n hw.ncpuonline)"cpu: "$(sysctl -n machdep.cpu_brand | tr -s " ")")"
		local disk_query="$(/bin/df -Pk 2>/dev/null | awk '/^\// {total+=$2; used+=$3}END{printf("%.1fGiB %.1fGiB %d%%\n", total/1048576, used/1048576, used*100/total)}')"
		local distro="$(uname -sr)"
		local host="$(echo "$(sysctl -n machdep.dmi.system-vendor) $(sysctl -n machdep.dmi.system-product)")"
		local kernel="$(echo "$(uname -m): $(sysctl -n kern.version | head -n1 | awk '{print $NF, $6, $7}')")"
		local memory_query="$(echo "$(sysctl -n hw.pagesize) $(sysctl -n hw.usermem64) $(vmstat -s | awk '/pages active$/ {print $1}')" | awk '{ print $2, $1 * $3 }')"
	elif [[ "$(uname)" == 'OpenBSD' ]]; then
		local cpu="$(echo "$(sysctl -n hw.ncpuonline)"cpu: "$(sysctl -n hw.model)")"
		local disk_query="$(/bin/df -Pk 2>/dev/null | awk '/^\// {total+=$2; used+=$3}END{printf("%.1fGiB %.1fGiB %d%%\n", total/1048576, used/1048576, used*100/total)}')"
		local distro="$(sysctl -n kern.version | head -n1 | awk '{print $1, $2}')"
		local gpu="$(/usr/X11R6/bin/glxinfo -B 2>/dev/null | awk '/OpenGL renderer string/ { sub(/OpenGL renderer string: /,""); print }')"
		local host="$(echo "$(sysctl -n hw.vendor) $(sysctl -n hw.product)")"
		local kernel="$(echo "$(uname -m): $(sysctl -n kern.version | head -n1 | awk '{print $NF, $6, $7}' | tr -d '()')")"
		local memory_query="$(echo "$(sysctl -n hw.pagesize) $(sysctl -n hw.usermem) $(vmstat -s | awk '/pages active$/ {print $1}')" | awk '{ print $2, $1 * $3 }')"
	else
		local cpu='unknown'
		local distro="$(uname)"
		local host='unknown'
		local kernel="$(uname -mr)"
		local memory_query='1 0'
	fi
	local disk_total="$(echo "${disk_query}" | awk '{print $1}')"
	local disk_used="$(echo "${disk_query}" | awk '{print $2}')"
	local disk_percent_used="$(echo "${disk_query}" | awk '{print $3}')"
	local memory_percent_used=$(echo "${memory_query}" | awk '{print $2/$1*100}' | awk -F'.' '{print $1}')
	local memory_total=$(echo "${memory_query}" | awk '{print $1/1024^2}' | awk -F'.' '{print $1}')
	local memory_used=$(echo "${memory_query}" | awk '{print $2/1024^2}' | awk -F'.' '{print $1}')
	case "${SHELL##*/}" in
		bash) local shell_version="${BASH_VERSION}" ;;
		zsh) local shell_version="${ZSH_VERSION}" ;;
		*) ;;
	esac
	local uptime="$(uptime | awk '{print $3, $4}' | sed 's/\,//g')"
	if [[ "$(echo "${uptime}" | awk -F':' '{print $1}')" != "${uptime}" ]]; then
		local uptime="$(echo "${uptime}" | awk -F':' '{print $1}') hour(s)"
	fi
	printf "\n\t%s@%s\n\n" "${LOGNAME}" "${HOSTNAME}"
	printf "OS:\t\t%s\n" "${distro}"
	printf "Kernel:\t\t%s\n" "${kernel}"
	printf "Uptime:\t\t%s\n" "${uptime}"
	if [[ -z "${shell_version}" ]]; then
		printf "Shell:\t\t%s\n" "${SHELL}"
	else
		printf "Shell:\t\t%s (%s)\n" "${SHELL}" "${shell_version}"
	fi
	printf "Host:\t\t%s\n" "${host}"
	printf "CPU:\t\t%s\n" "${cpu}"
	if [[ -n "${gpu}" ]]; then
		printf "GPU:\t\t%s\n" "${gpu}"
	fi
	if [[ -n "${disk_used}" ]]; then
		printf "Disk:\t\t%s / %s (%s)\n" "${disk_used}" "${disk_total}" "${disk_percent_used}"
	fi
	printf "RAM:\t\t%sMiB / %sMiB (%s%%)\n" "${memory_used}" "${memory_total}" "${memory_percent_used}"
}

whattimeisitin() {
	if [[ "${#}" == '0' ]]; then
		printf 'usage:\n    whattimeisitin CITY\n'
	fi
	local sanitized_input="$(echo $@ | sed 's/\ /_/g')"
	local zone="$(grep -im1 "\/${sanitized_input}" /usr/share/zoneinfo/zone.tab | awk '{print $3}')"
	if [[ -z "${zone}" ]]; then
		printf "%s '%s'.\n\n" "Unable to find IANA time zone identifier for" "${sanitized_input}"
		return 1
	else
		printf "%s: %s\n\n" "${zone}" "$(TZ=${zone} date)"
	fi
}

### enable emacs keybindings
set -o emacs

### source profile-local files
if [[ -r "${HOME}/.profile.local" ]]; then
	. "${HOME}/.profile.local"
fi

### git variables
export GIT_COMMITTER_EMAIL=${GIT_AUTHOR_EMAIL}
export GIT_COMMITTER_NAME=${GIT_AUTHOR_NAME}
if command -v got >/dev/null; then
	export GOT_AUTHOR="${GIT_AUTHOR_NAME} <${GIT_AUTHOR_EMAIL}>"
fi
