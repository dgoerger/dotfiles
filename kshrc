# ~/.kshrc, see ksh(1)
# docs: https://man.openbsd.org/ksh

### all operating systems and shells
## PATH
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/games:/usr/local/bin

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
unset  ENV
export BROWSER=lynx
export EDITOR=vi
export GIT_AUTHOR_EMAIL="${LOGNAME}@users.noreply.github.com"
export GIT_AUTHOR_NAME="$(getent passwd "${LOGNAME}" | cut -d: -f5 | cut -d, -f1)"
export HISTCONTROL=ignoredups
export HISTFILE=${HOME}/.history
export HISTSIZE=20736
export HOSTNAME=$(hostname -s)
if command -v jq >/dev/null 2>&1; then
	export JQ_COLORS='0;37:0;39:0;39:0;39:0;32:1;39:1;39'
fi
export LANG="en_CA.UTF-8"
export LC_ALL="en_CA.UTF-8"
export LESSSECURE=1
if [[ -r "${HOME}/.lynxrc" ]]; then
	if [[ -r "${HOME}/.elynxrc" ]]; then
		alias elynx='COLUMNS=80 lynx -cfg=~/.elynxrc -useragent "Mozilla/5.0 (Windows NT 10.0; rv:91.0) Gecko/20100101 Firefox/91.0" 2>/dev/null'
	fi
	export LYNX_CFG="${HOME}/.lynxrc"
	alias lynx='COLUMNS=80 lynx -useragent "Mozilla/5.0 (Windows NT 10.0; rv:91.0) Gecko/20100101 Firefox/91.0" 2>/dev/null'
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
	alias cvs='cvs -q'
fi
alias df='df -h'
alias ducks='du -ahxd1 | sort -hr'
alias free='top | grep -E "^Memory"'
if command -v git >/dev/null; then
	alias ggrep='git grep -in --'
fi
if command -v kpcli >/dev/null; then
	alias kpcli='kpcli --histfile=/dev/null --readonly --kdb'
fi
alias l='ls -1F'
alias lA='ls -AF'
alias la='ls -aFhl'
alias larth='ls -aFhlrt'
alias less='less -iLMR'
alias listening='netstat -lnp tcp && netstat -lnp udp'
alias ll='ls -Fhl'
alias ls='ls -F'
alias lS='ls -aFhlS'
if command -v mutt >/dev/null; then
	alias mail=mutt
fi
alias mtop='top -o res'
alias mv='mv -i'
if command -v newsboat >/dev/null; then
	alias news='newsboat -q'
fi
alias pscpu='ps -Awwro user,pid,ppid,nice,%cpu,%mem,vsz,rss,state,wchan,time,command'
alias psmem='ps -Awwmo user,pid,state,time,pagein,vsz,rss,tsiz,%cpu,%mem,command'
alias pssec='ps -Awwo pid,state,user,etime,rtable,comm,pledge'
alias rgrep='grep -rIns --'
alias rm='rm -i'
if ! command -v rsync >/dev/null && command -v openrsync >/dev/null; then
	alias rsync="$(command -v openrsync)"
fi
alias sha512='sha512 -q'
alias stat='stat -x'
alias tm='tmux new-session -A -s tm'
if command -v nvim >/dev/null; then
	alias vi=nvim
	alias view='nvim --cmd "let no_plugin_maps = 1" -c "runtime! macros/less.vim" -m -M -R -n'
else
	alias view=less
fi
alias w='w -i'

# kaomoji
alias disapprove='echo '\''ಠ_ಠ'\'''
alias kilroy='echo '\''ฅ^•ﻌ•^ฅ'\'''
alias rage='echo '\''(╯°□°）╯︵ ┻━┻'\'''
alias shrug='echo '\''¯\_(ツ)_/¯'\'''
alias stare='echo '\''(•_•)'\'''
alias sunglasses='echo '\''(■_■¬)'\'''
alias woohoo='echo \\\(ˆ˚ˆ\)/'


### OS-specific overrides
if [[ "$(uname)" == 'Darwin' ]]; then
	export LESSHISTFILE=-
	export MANWIDTH=80
	export SSH_AUTH_SOCK_PATH="${HOME}/.ssh/ssh-$(printf "%s@%s" "${LOGNAME}" "${HOSTNAME}" | shasum -a 256 | awk '{print $1}').socket"

	alias bc='bc -ql'
	alias cal='/usr/bin/ncal -C'
	alias dns_reset='sudo killall -HUP mDNSResponder; sudo killall mDNSResponderHelper; sudo dscacheutil -flushcache'
	alias ducks='du -hxd1 | sort -hr'
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
	export LESSHISTFILE=-

	alias bc='bc -lPq'
	alias cal='/usr/bin/ncal -C'
	alias checkupdates='pkg upgrade -Un'
	alias ducks='du -hxd1 | sort -hr'
	alias free='top | grep -E "^Mem"'
	alias listening='sockstat -l46'
	alias pssec='ps -Awo pid,state,user,etime,comm,jail'
	alias pstree='ps auxwd'

elif [[ "$(uname)" == 'Linux' ]]; then
	# env
	# as of less v594, we will no-longer need to disable LESSHISTFILE manually: https://github.com/gwsw/less/commit/9eba0da958d33ef3582667e09701865980595361
	export LESSHISTFILE=-
	unset  LS_COLORS
	if [[ -L "/bin" ]]; then
		# some Linux have /bin -> /usr/bin
		export PATH=/usr/local/bin:/bin:/sbin
	fi
	if [[ -d "${HOME}/bin" ]]; then
		export PATH=${HOME}/bin:${PATH}
	fi
	export SSH_AUTH_SOCK_PATH="${HOME}/.ssh/ssh-$(printf "%s@%s" "${LOGNAME}" "${HOSTNAME}" | sha256sum | awk '{print $1}').socket"
	export QUOTING_STYLE=literal

	# aliases
	function apropos {
		# man(1) default search order: 1,8,3,2,5,4,9,6,7
		man -s 1,8,5,4,6,7 -wK "${@}" | awk -F'(/|\\.)' '{system("/usr/bin/whatis " $(NF-2))}'
	}
	if command -v atop >/dev/null; then
		alias atop='atop -f'
	fi
	alias bc='bc -ql'
	bpftrace_open() {
		if ! command -v bpftrace >/dev/null 2>&1; then
			printf 'bpftrace(8) not installed, aborting...\n'
			return 1
		elif [[ -n "${1}" ]]; then
			case "${1}" in
				''|*[!0-9]*)
					printf 'ERROR: pid must be an integer\n'
					return 1
					;;
				*)
					PID="${1}"
					;;
			esac
			sudo bpftrace -e "tracepoint:syscalls:sys_enter_openat /pid == ${PID}/ { printf(\"%s %s\n\", comm, str(args->filename)); }"
		else
			printf 'usage\n    bpftrace_openat PID\n\n'
			return 1
		fi
	}
	alias date='LC_ALL=C /bin/date'
	if ! command -v doas >/dev/null; then
		alias doas=/usr/bin/sudo
	fi
	alias free='/usr/bin/free -h | sed "s/^Mem\:/Mem\:\ /; s/^Swap\:/Swap\:\ /; s/Ki/K\ /g; s/Mi/M\ /g; s/Gi/G\ /g; s/Ti/T\ /g; s/Pi/P\ /g; s/Ei/E\ /g;"'
	alias l='LC_ALL=C ls -1F --color=never'
	alias lA='LC_ALL=C ls -AF --color=never'
	alias la='LC_ALL=C ls -aFhl --color=never'
	alias larth='LC_ALL=C ls -aFhlrt --color=never'
	alias less='less -iMR'
	alias listening='ss -lntu'
	alias ll='LC_ALL=C ls -Fhl --color=never'
	alias ls='LC_ALL=C ls -F --color=never'
	alias lS='LC_ALL=C ls -aFhlS --color=never'
	alias mtop='top -s -o "RES"'
	alias pscpu='ps -Awwo user,pid,ppid,nice,pcpu,pmem,vsz:10,rss:8,stat,cputime,command --sort -pcpu,-vsz,-pmem,-rss'
	alias psmem='ps -Awwo user,pid,stat,cputime,majflt,vsz:10,rss:8,trs:8,pcpu,pmem,command --sort -rss,-vsz,-pcpu'
	alias pssec='ps -Awo pid,stat,user,etime,command,cgname'
	if ! command -v pstree >/dev/null; then
		alias pstree='ps auxwf'
	fi
	alias realpath='readlink -ev'
	unalias sha512
	function sha512 {
		sha512sum --tag "${1}" | awk '{print $NF}'
	}
	unalias stat
	alias top='top -s'
	if ! whence whence >/dev/null 2>&1; then
		# whence exists in ksh and zsh, but not in bash
		alias whence='command -v'
	fi
	if [[ -x /usr/bin/which ]]; then
		alias which=/usr/bin/which
	fi

	# distro-specific overrides
	if [[ -r /etc/alpine-release ]]; then
		alias checkupdates='apk list -u'
		unalias realpath
	elif [[ -r /etc/arch-release ]]; then
		alias checkupdates='pacman -Sup --print-format "%n %v"'
	elif [[ -r /etc/debian_version ]]; then
		if [[ -x /usr/bin/ncal ]]; then
			alias cal='/usr/bin/ncal -bM'
		fi
		alias checkupdates='apt list --upgradeable'
	elif [[ -r /etc/redhat-release ]]; then
		alias checkupdates='yum -q check-update'
	fi

	# manual pages
	if [[ "$(realpath /usr/bin/man)" != '/usr/bin/mandoc' ]]; then
		export MANWIDTH=80
		alias man='man --nh --nj'
	fi

elif [[ "$(uname)" == 'NetBSD' ]]; then
	export LESSHISTFILE=-
	export MANPATH=/usr/share/man:/usr/local/man
	export PS1="${HOSTNAME}$ "
	export SSH_AUTH_SOCK_PATH="${HOME}/.ssh/ssh-$(printf "%s@%s" "${LOGNAME}" "${HOSTNAME}" | cksum -a SHA256 | awk '{print $1}').socket"

	alias apropos='/usr/bin/apropos -l'
	alias cal='/usr/bin/cal -d1'
	unalias free
	alias listening='netstat -anf inet | grep -Ev "(ESTABLISHED|TIME_WAIT|FIN_WAIT_1|FIN_WAIT_2)$"'
	alias pkgsrc='ftp -Vo - "https://ftp.netbsd.org/pub/pkgsrc/packages/NetBSD/x86_64/$(uname -r)/All/" 2>/dev/null | less'
	unalias pssec
	alias pstree='ps auxwd'
	alias realpath='readlink -fv'
	unalias sha512
	function sha512 {
		cksum -a SHA512 "${1}" | awk '{print $NF}'
	}

elif [[ "$(uname)" == 'OpenBSD' ]]; then
	export SSH_AUTH_SOCK_PATH="${HOME}/.ssh/ssh-$(printf "%s@%s" "${LOGNAME}" "${HOSTNAME}" | sha256).socket"

	# aliases
	apropos() {
		# search all sections of the manual by default
		/usr/bin/man -k any="${1}"
	}
	if sysctl -n kern.version | grep -qE "\-(current|beta)"; then
		checkupdates() {
			# on -current, check if there's a newer snap available
			local _buildshasum="$(ftp -VMo - "$(cat /etc/installurl)/snapshots/$(uname -m)/SHA256" | sha512 -q)"
			local _builddate="$(ftp -VMo - "$(cat /etc/installurl)/snapshots/$(uname -m)/BUILDINFO" | awk -F ' - ' '{print $NF}')"
			local _installshasum="$(sha512 -q /var/db/installed.SHA256)"
			local _installdate="$(sysctl -n kern.version | head -n 1 | awk -F': ' '{print $NF}' | sed 's/MST//' | sed 's/MDT//')"
			if [[ "${_buildshasum}" != "${_installshasum}" ]]; then
				printf "Updates are available via sysupgrade(8).\n\n"
				printf "Running: %s\n" "$(TZ='Canada/Mountain' date -z 'Canada/Mountain' -jf "%a %b %e %H:%M:%S %Y" "${_installdate}" +"%Y%m%d %H:%M:%S")"
				printf "Upgrade: %s\n" "$(TZ=UTC date -z 'Canada/Mountain' -jf "%a %b %e %H:%M:%S %Z %Y" "${_builddate}" +"%Y%m%d %H:%M:%S")"
			else
				printf "System is up-to-date.\n"
			fi
		}
	else
		checkupdates() {
			# on -stable, check if there are available syspatches
			local _availablepatches="$(ftp -VMo - "$(cat /etc/installurl)/syspatch/$(uname -r)/$(uname -m)/SHA256" | awk '!/^$/ {print $2}' | tail -n 1)"
			local _installedpatches="$(echo "(syspatch$(/bin/ls -hrt /var/syspatch/ | tail -n 1).tgz)")"
			if [[ "${_installedpatches}" != "${_availablepatches}" ]]; then
				printf "Updates are available via syspatch(8).\n"
			else
				printf "System is up-to-date.\n"
			fi
		}
	fi
	usrlocal_extras() {
		# function to identify files in /usr/local which aren't claimed by an installed package
		local LOCAL_FILES="$(mktemp)"
		local PKG_FILES="$(mktemp)"

		find -L /usr/local/ -type f | sort -u | grep -Ev "^/usr/local/(share/mime|info/dir|lib/qt5/include|man/mandoc.db$|.*\.cache$)" > "${LOCAL_FILES}"
		pkg_mklocatedb -nq | awk -F':' '{$1=""; print $0}' | sed 's/^\ //g' | sed 's/\ \ /::/g' | grep -E "^/usr/local" | sort -u | grep -Ev "/$" | grep -v '/usr/local/share/mime' > "${PKG_FILES}"

		diff -U0 -L pkg_files -L installed_files "${PKG_FILES}" "${LOCAL_FILES}" | grep -Ev "^\@" | awk '/^\@/ {printf "\033[0;96m%s\033[0;0m\n", $0} /^\-/ {printf "\033[0;91m%s\033[0;0m\n", $0} /^\+/ {printf "\033[0;92m%s\033[0;0m\n", $0} /^\ / {printf "\033[0;0m%s\033[0;0m\n", $0}'
	}
fi


# ksh tab completions
if [[ "${0}" == '-ksh' ]] || [[ "${0}" == 'ksh' ]]; then
	export HOST_LIST=$(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts | sort -u)

	set -A complete_diff_1 -- -u
	set -A complete_dig_1 -- ${HOST_LIST}
	set -A complete_git_1 -- add bisect blame checkout clone commit diff log mv pull push rebase reset revert rm stash status submodule
	set -A complete_got_1 -- add backout blame branch cat checkout cherrypick clone commit diff fetch histedit import info init integrate log rebase ref remove revert stage status tag tree unstage update
	set -A complete_host_1 -- ${HOST_LIST}
	if command -v ifconfig >/dev/null; then
		set -A complete_ifconfig_1 -- $(ifconfig | awk -F':' '/^[a-z]/ {print $1}')
	fi
	set -A complete_kill_1 -- -9 -HUP -INFO -KILL -TERM
	if [[ -r /usr/local/etc/manuals.list ]]; then
		set -A complete_man_1 -- $(cat /usr/local/etc/manuals.list)
	fi
	set -A complete_nc_1 -- -c -cv -v ${HOST_LIST}
	set -A complete_openrsync_1 -- -vaxx
	set -A complete_openrsync_2 -- --rsync-path=/usr/bin/openrsync
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
	set -A complete_search_1 -- alpine arxiv cve debian fedora freebsd mandebian mandragonflybsd manfreebsd manillumos manlinux mannetbsd manopenbsd mbug nws rfc rhbz ubuntu wikipedia wiktionary
	set -A complete_ssh_1 -- ${HOST_LIST}
	set -A complete_systat_1 -- buckets cpu ifstat iostat malloc mbufs netstat nfsclient nfsserver pf pigs pool pcache queues rules sensors states swap vmstat uvm
	set -A complete_tmux_1 -- attach list-commands list-sessions list-windows new-session new-window source
	set -A complete_traceroute_1 -- ${HOST_LIST}
	set -A complete_traceroute6_1 -- ${HOST_LIST}
	if pgrep -qf /usr/sbin/vmd >/dev/null 2>&1; then
		set -A complete_vmctl_1 -- console load reload start stop reset status send receive
		set -A complete_vmctl -- $(vmctl status | awk '!/NAME/{print $NF}')
	fi
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
		if [[ $# -eq 1 ]]; then
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
	# FIXME this strategy isn't safe for removing '/' from a filename
	#       as it's the path directory separator, so do not handle
	#       that char for now
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
if command -v tmux >/dev/null && command -v notify-send >/dev/null && [[ -n "${DESKTOP_SESSION}" ]]; then
	# GNOME3 - libnotify "toaster" popup
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
elif command -v leave >/dev/null; then
	# headless!
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
		printf "rename() ksh function defined in ~/.kshrc\n" && return 0
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

# sshinit() ssh-agent initialiser
sshinit() {
	if [[ -z "${SSH_AUTH_SOCK}" ]] || [[ -n "$(echo "${SSH_AUTH_SOCK}" | grep -E "^/run/user/$(id -u)/keyring/ssh$")" ]] || [[ -n "$(echo "${SSH_AUTH_SOCK}" | grep -E "^/private/tmp/com.apple.launchd.*/Listeners$")" ]]; then
		# if ssh-agent isn't running OR GNOME Keyring controls the socket OR we're on macOS
		if [[ -w "${HOME}" ]] && [[ -n "${SSH_AUTH_SOCK_PATH}" ]]; then
			export SSH_AUTH_SOCK="${SSH_AUTH_SOCK_PATH}"
		else
			printf "ERROR: unable to create \$SSH_AUTH_SOCK_PATH\n" && return 1
		fi
		if [[ ! -S "${SSH_AUTH_SOCK}" ]]; then
			eval $(ssh-agent -s -a "${SSH_AUTH_SOCK}" >/dev/null)
		elif ! pgrep -U "${LOGNAME}" -f "ssh-agent -s -a ${SSH_AUTH_SOCK}" >/dev/null 2>&1; then
			if [[ -S "${SSH_AUTH_SOCK}" ]]; then
				# if proc isn't running but the socket exists, remove and restart
				/bin/rm "${SSH_AUTH_SOCK}"
				eval $(ssh-agent -s -a "${SSH_AUTH_SOCK}" >/dev/null)
			fi
		fi
	else
		printf "ssh-agent is already listening on %s\n" "${SSH_AUTH_SOCK}" && return 1
	fi
}

# whattimeisitin() time zone query
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

# zless() implementation which doesn't rely on LESSPIPE
#     .. LESSPIPE pipe commands are incompatible with LESSSECURE=1;
#     .. rather than disable security (e.g. 'alias zless="LESSSECURE= /usr/bin/zless"'),
#     .. use an alternative implementation from the OpenBSD Project
if [[ "$(uname)" == 'Linux' ]] || [[ "$(uname)" == 'FreeBSD' ]]; then
	zless() {
		# $OpenBSD: zmore,v 1.9 2019/01/25 00:19:26 millert Exp $
		#
		# Copyright (c) 2003 Todd C. Miller <millert@openbsd.org>
		# 
		# Permission to use, copy, modify, and distribute this software for any
		# purpose with or without fee is hereby granted, provided that the above
		# copyright notice and this permission notice appear in all copies.
		#
		# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
		# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
		# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
		# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
		# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
		# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
		# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
		#
		# Sponsored in part by the Defense Advanced Research Projects
		# Agency (DARPA) and Air Force Research Laboratory, Air Force
		# Materiel Command, USAF, under agreement number F39502-99-1-0512.
		#
		
		# Pull out any command line flags so we can pass them to more/less
		flags=
		while test $# -ne 0; do
			case "${1}" in
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
		
		# No files means read from stdin
		if [[ ${#} -eq 0 ]]; then
			gzip -cdf 2>&1 | less ${flags}
			return 0
		fi
		
		oterm="$(stty -g 2>/dev/null)"
		while test $# -ne 0; do
			gzip -cdf "${1}" 2>&1 | less ${flags}
			prev="${1}"
			shift
			if tty -s && test -n "${oterm}" -a ${#} -gt 0; then
				echo -n "${prev} (END) - Next: ${1} "
				trap "stty ${oterm} 2>/dev/null" 0 1 2 3 13 15
				stty cbreak -echo 2>/dev/null
				REPLY="$(dd bs=1 count=1 2>/dev/null)"
				stty "${oterm}" 2>/dev/null
				trap - 0 1 2 3 13 15
				echo
				case "${REPLY}" in
					s)
						shift
						;;
					e|q)
						break
						;;
				esac
			fi
		done
	}
fi


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

### fix ssh agent forwarding workstation->jumpbox
if [[ "${HOSTNAME}" == "${SSH_JUMPBOX}" ]] && echo "${SSH_AUTH_SOCK}" | grep -qE "^/tmp/ssh-.*/agent\."; then
	if [[ -w "${HOME}" ]] && [[ -S "${SSH_AUTH_SOCK}" ]] && [[ "${SSH_AUTH_SOCK}" != "$(realpath "${SSH_AUTH_SOCK_PATH}" 2>/dev/null)" ]]; then
		/bin/ln -sf "${SSH_AUTH_SOCK}" "${SSH_AUTH_SOCK_PATH}"
	fi
	export SSH_AUTH_SOCK="${SSH_AUTH_SOCK_PATH}"
fi