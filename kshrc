# ~/.kshrc, see ksh(1)
# docs: https://man.openbsd.org/ksh

### all operating systems and shells
## PATH
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin

## terminal settings
# disable terminal flow control (^S/^Q)
stty -ixon
# disable job control (^Z), prevent clobber, set pipefail
set +m -Co pipefail
# SIGINFO: see signal(3)
stty status ^T 2>/dev/null
# restrict umask (override in ~/.profile.local)
umask 077


## environment variables
unset  ENV
export EDITOR=vi
export GIT_AUTHOR_EMAIL="${LOGNAME}@users.noreply.github.com"
export GIT_AUTHOR_NAME="$(getent passwd "${LOGNAME}" | cut -d: -f5 | cut -d, -f1)"
export HISTCONTROL=ignoredups
export HISTFILE="${HOME}/.history"
export HISTSIZE=20736
export HOSTNAME="$(hostname -s)"
export LANG="en_CA.UTF-8"
export LC_ALL="en_CA.UTF-8"
export LESSSECURE=1
if [[ -r "${HOME}/.lynxrc" ]]; then
	export LYNX_CFG="${HOME}/.lynxrc"
	alias lynx='COLUMNS=80 lynx -useragent "Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0" 2>/dev/null'
fi
export OS="$(uname)"
if [[ -r "${HOME}/.pythonrc" ]]; then
	export PYTHONSTARTUP="${HOME}/.pythonrc"
fi
export TZ='America/New_York'
export VISUAL="${EDITOR}"


## aliases
alias bc='bc -l'
alias cal='cal -m'
if command -v calendar >/dev/null && [[ -r "${HOME}/.calendar" ]]; then
	alias calendar='calendar -f ${HOME}/.calendar'
fi
alias cp='cp -i'
alias df='df -h'
alias ducks='du -ahxd1 | sort -hr'
alias free='top | grep -E "^Memory"'
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
alias pscpu='ps -Awwro uid,pid,ppid,pgid,%cpu,%mem,lstart,stat,wchan,time,command'
alias psmem='ps -Awwmo uid,pid,ppid,pgid,%cpu,%mem,lstart,stat,wchan,time,command'
alias pstree='ps -Awwfo uid,pid,ppid,pgid,%cpu,%mem,stat,wchan,time,command'
if ! command -v rg >/dev/null; then
	alias rg='grep -EIinrs --'
fi
alias rm='rm -i'
alias stat='stat -x'
alias tm='cd && tmux new-session -A -s tm'
if command -v bat >/dev/null; then
	alias v='bat --theme="Monokai Extended Origin" --paging=always --pager="less -iLMR"'
else
	alias v='less -iLMR'
fi
if command -v nvim >/dev/null; then
	alias vi='nvim -i NONE'
fi
alias view=v
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
if [[ "${OS}" == 'Darwin' ]]; then
	export LESSHISTFILE=-
	export MANWIDTH=80

	getent() {
		usage() {
			printf "usage:\n\tgetent group GROUPNAME\n\tgetent hosts HOSTNAME\n\tgetent passwd USERNAME\n"
		}
		if [[ "${#}" == '1' ]]; then
			if [[ "${1}" == '-h' ]] || [[ "${1}" == '--help' ]]; then
				usage
				return 0
			else
				usage
				return 1
			fi
		elif [[ "${#}" == '2' ]]; then
			case "${1}" in
				group)
					dscacheutil -q group -a name "${2}"
					;;
				hosts)
					dscacheutil -q host -a name "${2}"
					;;
				passwd)
					dscacheutil -q user -a name "${2}"
					;;
				*)
					usage
					return 1
					;;
			esac
		else
			usage
			return 1
		fi
		unset -f usage
	}

	alias dns_reset='sudo killall -HUP mDNSResponder; sudo killall mDNSResponderHelper; sudo dscacheutil -flushcache'
	alias ducks='du -hxd1 | sort -hr'
	alias ldd='otool -L'
	alias mtop='top -o mem'
	alias realpath='readlink'

elif [[ "${OS}" == 'Linux' ]]; then
	# env
	export LS_COLORS='no=00:fi=00:rs=0:di=00:ln=00:mh=00:pi=00:so=00:do=00:bd=00:cd=00:or=00:mi=00:su=00:sg=00:ca=00:tw=00:ow=00:st=00:ex=00'
	if [[ -L "/bin" ]]; then
		# some Linux have /bin -> /usr/bin
		export PATH=/usr/local/bin:/bin:/sbin
	fi
	if [[ -d "${HOME}/bin" ]]; then
		export PATH=${HOME}/bin:${PATH}
	fi
	export SSH_AUTH_SOCK_PATH="${HOME}/.ssh/ssh-$(printf "%s@%s" "${LOGNAME}" "${HOSTNAME}" | sha256sum | awk '{print $1}').socket"

	# aliases
	if command -v atop >/dev/null; then
		alias atop='atop -f'
	fi
	if ! command -v doas >/dev/null; then
		alias doas=/usr/bin/sudo
	fi
	unalias free
	function free {
		# FOR COMPATIBILITY with procps-ng, and to ensure safe scripting, revert
		#     to procps-ng's implementation whenever argc > 1
		if [[ "${#}" -gt 0 ]]; then
			if [[ -x /usr/bin/free ]]; then
				/usr/bin/free "${@}"
				return $?
			else
				printf "command not found: /usr/bin/free\n"
				return 1
			fi
		fi

		# format for human-readable output
		scale() {
			printf "%s\n" "${1}" | awk -v CONVFMT='%.1f' '{ split( "K M G T E" , v ); s=1; while( $1>1024 ){ $1/=1024; s++ } print $1 v[s] }'
		}

		# source /proc/meminfo ONCE to avoid inconsistencies stemming from multiple reads
		local MEMINFO="$(cat /proc/meminfo)"; readonly MEMINFO

		# maths
		local TOTAL="$(echo "${MEMINFO}" | awk '/^MemTotal:/ {print $2}')"; readonly TOTAL
		local FREE="$(echo "${MEMINFO}" | awk '/^MemFree:/ {print $2}')"; readonly FREE
		local AVAIL="$(echo "${MEMINFO}" | awk '/^MemAvailable:/ {print $2}')"; readonly AVAIL
		local SHARED="$(echo "${MEMINFO}" | awk '/^Shmem:/ {print $2}')"; readonly SHARED
		local CACHE="$(echo "${MEMINFO}" | awk '/^Cached:/ {print $2}')"; readonly CACHE
		local BUFFERS="$(echo "${MEMINFO}" | awk '/^Buffers:/ {print $2}')"; readonly BUFFERS
		local HUGEPAGE_TOTAL="$(echo "${MEMINFO}" | awk '/^Hugetlb:/ {print $2}')"; readonly HUGEPAGE_TOTAL
		local HUGEPAGE_BLOCKS_FREE="$(echo "${MEMINFO}" | awk '/HugePages_Free:/ {print $2}')"; readonly HUGEPAGE_BLOCKS_FREE
		local HUGEPAGE_BLOCKS_SIZE="$(echo "${MEMINFO}" | awk '/Hugepagesize:/ {print $2}')"; readonly HUGEPAGE_BLOCKS_SIZE
		local SLAB="$(echo "${MEMINFO}" | awk '/^SReclaimable:/ {print $2}')"; readonly SLAB
		local SWAP_TOTAL="$(echo "${MEMINFO}" | awk '/^SwapTotal:/ {print $2}')"; readonly SWAP_TOTAL
		local SWAP_FREE="$(echo "${MEMINFO}" | awk '/^SwapFree:/ {print $2}')"; readonly SWAP_FREE
		local SWAP_CACHE="$(echo "${MEMINFO}" | awk '/^SwapCached:/ {print $2}')"; readonly SWAP_CACHE
		local COMMIT_LIMIT="$(echo "${MEMINFO}" | awk '/^CommitLimit:/ {print $2}')"; readonly COMMIT_LIMIT
		local COMMIT_USED="$(echo "${MEMINFO}" | awk '/^Committed_AS:/ {print $2}')"; readonly COMMIT_USED
		local HUGEPAGE_FREE="$(echo "${HUGEPAGE_BLOCKS_FREE} * ${HUGEPAGE_BLOCKS_SIZE}" | bc -l)"; readonly HUGEPAGE_FREE
		local SWAP_USED="$(echo "${SWAP_TOTAL} - ${SWAP_CACHE} - ${SWAP_FREE}" | bc -l)"; readonly SWAP_USED
		local BUFFCACHE="$(echo "${BUFFERS} + ${CACHE} + ${SLAB}" | bc -l)"; readonly BUFFCACHE
		local HUGEPAGE_USED="$(echo "${HUGEPAGE_TOTAL} - ${HUGEPAGE_FREE}" | bc -l)"; readonly HUGEPAGE_USED
		local USED="$(echo "${TOTAL} - ${BUFFERS} - ${CACHE} - ${FREE} - ${SLAB} - ${HUGEPAGE_FREE} - ${HUGEPAGE_USED}" | bc -l)"; readonly USED
		local NONHUGEPAGE_TOTAL="$(echo "${TOTAL} - ${HUGEPAGE_TOTAL}" | bc -l)"; readonly NONHUGEPAGE_TOTAL
		local COMMIT_PERCENT="$(echo "result = (${COMMIT_USED} / ${COMMIT_LIMIT}) * 100; scale=0; result/1" | bc -l)"; readonly COMMIT_PERCENT
		
		# print memory usage
		printf "\ttotal\tused\tfree\tshared\tcached\tavail\tvmcom\n"
		printf "Mem:\t%s\t%s\t%s\t%s\t%s\t%s\t%s%%\n" "$(scale ${NONHUGEPAGE_TOTAL})" "$(scale ${USED})" "$(scale ${FREE})" "$(scale ${SHARED})" "$(scale ${BUFFCACHE})" "$(scale ${AVAIL})" "${COMMIT_PERCENT}"
		
		# only print the hugepages line if hugepages are enabled
		if [[ "${HUGEPAGE_TOTAL}" != '0' ]]; then
			printf "HugePg:\t%s\t%s\t%s\n" "$(scale ${HUGEPAGE_TOTAL})" "$(scale ${HUGEPAGE_USED})" "$(scale ${HUGEPAGE_FREE})"
		fi
		
		# only print the swap line if swap is enabled
		if [[ "${SWAP_TOTAL}" != '0' ]]; then
			printf "Swap:\t%s\t%s\t%s\n" "$(scale ${SWAP_TOTAL})" "$(scale ${SWAP_USED})" "$(scale ${SWAP_FREE})"
		fi

		unset -f scale
	}
	alias mtop='top -s -o "RES"'
	alias pscpu='ps -Awwo uid,pid,ppid,pgid,pcpu,pmem,lstart,stat,wchan,time,command --sort -pcpu,-pmem'
	alias psmem='ps -Awwo uid,pid,ppid,pgid,pcpu,pmem,lstart,stat,wchan,time,command --sort -pmem,-pcpu'
	unalias pstree
	unalias stat
	alias top='top -s'
	if ! whence whence >/dev/null 2>&1; then
		# whence exists in ksh and zsh, but not in bash
		alias whence='command -v'
	fi
	if [[ -x /usr/bin/which ]]; then
		alias which=/usr/bin/which
	fi
	if [[ "${SHELL}" == '/bin/ksh' ]]; then
		export PS1="${HOSTNAME}$ "
	fi

	# distro-specific overrides
	if [[ -r /etc/alpine-release ]]; then
		alias checkupdates='apk list -u'
		alias ducks='du -akxd1 | sort -nr'
		alias listening='netstat -antpl'
		if command -v flatpak >/dev/null 2>&1; then
			alias pkgup='doas /bin/sh -c "/sbin/apk update && /sbin/apk upgrade && /usr/bin/flatpak update -y && /usr/bin/flatpak uninstall -y --unused && /sbin/apk fix -s"'
		else
			alias pkgup='doas /bin/sh -c "/sbin/apk update && /sbin/apk upgrade && /sbin/apk fix -s"'
		fi
		unalias realpath
		if [[ -x /usr/sbin/zzz ]]; then
			alias zzz='doas /usr/sbin/zzz'
		fi
	elif [[ -r /etc/debian_version ]]; then
		# with less(1) v594, we no-longer need to disable LESSHISTFILE manually
		# .. https://github.com/gwsw/less/commit/9eba0da958d33ef3582667e09701865980595361
		export LESSHISTFILE=-
		export QUOTING_STYLE=literal

		if [[ -x /usr/bin/ncal ]]; then
			alias cal='/usr/bin/ncal -bM'
		fi
		alias date='LC_ALL=C /bin/date'
		alias checkupdates='apt list --upgradeable'
		alias listening='ss -lntu'
		alias pkgextras='apt list "~o"'
		if [[ -r /etc/pop-os/issue ]]; then
			alias pkgup='/usr/bin/sudo /bin/bash -c "/bin/apt update && /bin/apt upgrade -y && /bin/flatpak update --system -y && /bin/flatpak uninstall --system --unused -y"'
		fi
		alias realpath='readlink -ev'
		unalias w
		function w {
			local W="$(/usr/bin/w -shi)"
			printf "${W}" | grep -v days | sort -hk4
			printf "${W}" | grep days | sort -hk4
		}
	fi
	# zless() implementation which doesn't rely on LESSPIPE
	#     .. LESSPIPE pipe commands are incompatible with LESSSECURE=1;
	#     .. rather than disable security (e.g. 'alias zless="LESSSECURE= /usr/bin/zless"'),
	#     .. use an alternative implementation from the OpenBSD Project
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

	# manual pages
	if [[ "$(realpath /usr/bin/man)" != '/usr/bin/mandoc' ]]; then
		export MANWIDTH=80
		alias man='man --nh --nj'
	fi

elif [[ "${OS}" == 'OpenBSD' ]]; then
	export SSH_AUTH_SOCK_PATH="${HOME}/.ssh/ssh-$(printf "%s@%s" "${LOGNAME}" "${HOSTNAME}" | sha256).socket"

	# aliases
	apropos() {
		# search all sections of the manual by default
		/usr/bin/man -k any="${1}"
	}
	if sysctl -n kern.version | grep -E "\-(current|beta)" >/dev/null 2>&1; then
		alias checkupdates='doas /bin/ksh -c "/usr/bin/timeout -sINT 3s /usr/sbin/sysupgrade -ns"'
	else
		alias checkupdates='doas /usr/sbin/syspatch -c'
	fi
	alias patch='patch --posix'
	alias pkgup='doas /usr/sbin/pkg_add -Vu'
	pkgextras() {
		# function to identify files in /usr/local which aren't claimed by an installed package
		local LOCAL_FILES="$(mktemp)"
		local PKG_FILES="$(mktemp)"

		find -L /usr/local/ -type f | sort -u | grep -Ev "^/usr/local/(share/mime|info/dir|lib/qt5/include|man/mandoc.db$|.*\.cache$)" >| "${LOCAL_FILES}"
		pkg_mklocatedb -nq | awk -F':' '{$1=""; print $0}' | sed 's/^\ //g' | sed 's/\ \ /::/g' | grep -E "^/usr/local" | sort -u | grep -Ev "/$" | grep -Fv '/usr/local/share/mime' >| "${PKG_FILES}"

		/usr/bin/diff -U0 -L pkg_files -L installed_files "${PKG_FILES}" "${LOCAL_FILES}" | grep -Ev "^\@" | awk '/^\-/ {printf "\033[38;5;125m%s\033[38;5;m\n", $0} /^\+/ {printf "\033[38;5;28m%s\033[38;5;m\n", $0}'
		/bin/rm "${LOCAL_FILES}" "${PKG_FILES}"
	}
	if [[ -x /usr/local/sbin/sysclean ]]; then
		alias sysclean='doas /usr/local/sbin/sysclean'
	fi
fi


# ksh tab completions
if [[ "${0}" == '-ksh' ]] || [[ "${0}" == 'ksh' ]]; then
	export HOST_LIST=$(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts 2>/dev/null | sort -u)

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
	set -A complete_ping_1 -- ${HOST_LIST}
	set -A complete_ping6_1 -- ${HOST_LIST}
	if [[ "${OS}" == 'OpenBSD' ]] && [[ -r /etc/rc.d ]]; then
		set -A complete_rcctl_1 -- disable enable get ls order set
		set -A complete_rcctl_2 -- $(rcctl ls all)
	fi
	#set -A complete_rsync_1 -- -HhLPSprtv
	set -A complete_sftp_1 -- -p
	set -A complete_sftp_2 -- ${HOST_LIST}
	set -A complete_ssh_1 -- ${HOST_LIST}
	if pgrep -qf /usr/sbin/vmd >/dev/null 2>&1; then
		set -A complete_vmctl_1 -- console load reload start stop reset status send receive
		set -A complete_vmctl -- $(vmctl status | awk '!/NAME/{print $NF}')
	fi
fi


### functions
# def() look up the definition of a word
def() {
	if [[ $# -eq 1 ]]; then
		printf "D gcide %s\nQ\n" "${1}" | nc dict.org 2628 | grep -Ev "^(150|220|221|250|\.)"
	else
		printf "usage:\n\tdef WORD\n"
		return 1
	fi
}

# diff() with syntax highlighting
diff() {
	if [[ "${#}" == '0' ]]; then
		diff="$(git diff 2>/dev/null || got diff 2>/dev/null)"
		if [[ "${?}" != '0' ]]; then
			/usr/bin/diff
			return $?
		fi
	elif [[ "${#}" == '3' ]] && [[ "${1}" == '-u' ]] && [[ -r "${2}" ]] && [[ -r "${3}" ]]; then
		diff="$(/usr/bin/diff -u "${2}" "${3}")"
	else
		/usr/bin/diff "${@}"
		return $?
	fi
	# nota bene: [[ -t 1 ]] => "is output to stdout," versus to a pipe or file
	if [[ -t 1 ]]; then
		printf "%s" "${diff}" | awk '/^\@/ {printf "\033[0;96m%s\033[0;0m\n", $0}
			/^\-/ {printf "\033[38;5;125m%s\033[38;5;m\n", $0}
			/^\+/ {printf "\033[38;5;28m%s\033[38;5;m\n", $0}
			/^(\ |[a-z])/ {printf "\033[0;0m%s\033[0;0m\n", $0}'
	else
	      	printf "%s\n" "${diff}"
	fi
	unset diff
}

# fd() find files and directories
if ! command -v fd >/dev/null; then
	fd() {
		if [[ "${#}" != '1' ]]; then
			printf "usage:\n\tfd FILENAME\n"
		else
			find . -iname "*${1}*"
		fi
	}
fi

# info() retrieve information from the Internet
if command -v reader >/dev/null && command -v lowdown >/dev/null; then
	info() {
		usage() {
			printf "usage:\n\tinfo [KEYWORD] [QUERY]\n\nSupported KEYWORDs:\n"
			printf "\t* alpine PKG      - search the package repositories for Alpine Linux\n"
			printf "\t* debian PKG      - search the package repositories for Debian Linux\n"
			printf "\t* mandebian CMD   - retrieve manuals from the Debian Project\n"
			printf "\t* manobsd CMD     - retrieve manuals from the OpenBSD Project\n"
			printf "\t* nws ZIPCODE     - retrieve forecasts from the US National Weather Service\n"
			printf "\t* rfc NUMBER      - retrieve the text of a published IETF RFC\n"
			printf "\t* thesaurus WORD  - query the Oxford Dictionary thesaurus\n"
			printf "\t* wikipedia WORD  - query Wikipedia, the free encyclopedia\n"
			printf "\t* wiktionary WORD - query Wiktionary, the free dictionary\n"
			printf "\t* www HTTPS_URL   - retrieve a single webpage by URL\n"
		}
		
		# try to guess preferred language from $LANG
		if [[ -n "${LANG}" ]]; then
			local lang="$(echo "${LANG}" | cut -c1-2)"; readonly lang
		else
			local lang='en'; readonly lang
		fi
		
		# escape characters for URL-encoding
		escape_html() {
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
		
		# browser
		open_html() {
			reader -oi "${1}" | lowdown --parse-no-intraemph -st term | less
		}
		
		if [[ "${#}" == '0' ]] || [[ "${1}" == '-h' ]] || [[ "${1}" == '--help' ]]; then
			usage
			return 0
		elif [[ "${#}" -lt 2 ]]; then
			usage
			return 1
		else
			local site="${1}"; readonly site
			shift
			local query="$(escape_html "$@")"; readonly query
		fi
		
		case "${site}" in
			apk|alpine)
				open_html "https://pkgs.alpinelinux.org/packages?name=${query}&branch=edge&arch=x86_64"
				;;
			deb|debian)
				open_html "https://tracker.debian.org/search?package_name=${query}"
				;;
			man|manobsd|manopenbsd)
				open_html "https://man.openbsd.org/?sec=0&arch=default&manpath=OpenBSD-current&query=${query}"
				;;
			mandeb|mandebian)
				open_html "https://manpages.debian.org/jump?q=${query}"
				;;
			nws)
				open_html "https://forecast.weather.gov/zipcity.php?inputstring=${query}&btnSearch=Go&unit=1"
				;;
			rfc)
				open_html "https://tools.ietf.org/rfc/rfc${query}.txt"
				;;
			thesaurus)
				open_html "https://en.oxforddictionaries.com/thesaurus/${query}"
				;;
			w|wikipedia)
				open_html "https://${lang}.wikipedia.org/w/index.php?search=${query}&title=Special%3ASearch&go=Go"
				;;
			wikt|wiktionary)
				open_html "https://${lang}.wiktionary.org/w/index.php?search=${query}&title=Special%3ASearch&go=Go"
				;;
			www)
				open_html "${1}"
				;;
			*)
				usage
				return 1
				;;
		esac
	unset -f escape_html open_html usage
	}
fi

# photo_import() import photos from an SD card
if command -v exiv2 >/dev/null; then
	photo_import() {
		_import_photo() {
			local DATETIME="$(exiv2 -pt -qK Exif.Photo.DateTimeOriginal "${1}" 2>/dev/null | awk '{print $(NF-1)}' | sed 's/\:/\//g' | sort -u)"
			local FILENAME="$(echo "${1}" | awk -F"/" '{print $NF}' | tr '[:upper:]' '[:lower:]')"
			local PHOTO_DIR="${HOME}/Pictures"
	
			# sanity checks
			if [[ -z "${DATETIME}" ]]; then
				echo "${1}: Abort! DateTime not found" && return 1
			elif [[ "$(echo "${DATETIME}" | wc -l)" -ne 1 ]]; then
				echo "${1}: Abort! File has more than one DateTime declaration" && return 1
			elif [[ "${OS}" == 'OpenBSD' ]]; then
				if ! date -j "$(echo "${DATETIME}/0000" | sed 's/\///g')" >/dev/null 2>&1; then
					echo "${1}: Abort! /bin/date doesn't recognise the detected DateTime as a valid date" && return 1
				fi
			elif [[ "${OS}" == 'Linux' ]]; then
				if ! date --date="$(echo "${DATETIME}" | sed 's/\///g')" >/dev/null 2>&1; then
					echo "${1}: Abort! /bin/date doesn't recognise the detected DateTime as a valid date" && return 1
				fi
			fi
	
			# copy the file into place
			if [[ -n "${FILENAME}" ]]; then
				mkdir -p "${PHOTO_DIR}/${DATETIME}"
				if [[ ! -f "${PHOTO_DIR}/${DATETIME}/${FILENAME}" ]]; then
					install -pm 0444 "${1}" "${PHOTO_DIR}/${DATETIME}/${FILENAME}"
				fi
			fi
		}
		# This script will search recursively for exif metadata in supported
		#   files within the current directory, and copy images to
		#   $PHOTO_DIR/$YYYY/$MM/$DD
		local FILETYPES="jpg jpeg"
		for x in ${FILETYPES}; do
			find . -type f -iname "*.${x}" | while read -r photo; do _import_photo "${photo}"; done
		done
		unset -f _import_photo
	}
fi

# pomodoro() timer
pomodoro() {
	usage() {
		printf 'usage:\n\tpomodoro minutes [message]\n'
	}
	if [[ ${#} -eq 0 ]] || [[ "${1}" == '-h' ]] || [[ "${1}" == '--help' ]]; then
		usage
		return 0
	elif [[ ${#} -eq 1 ]]; then
		local minutes="${1}"
		local message="Time's up!"
	elif [[ ${#} -ge 2 ]]; then
		local minutes="${1}"
		shift
		local message="${@}"
	fi
	case "${minutes}" in
		''|*[!0-9]*)
			printf "Error: 'minutes' must be an integer.\n"
			usage
			return 1
			;;
		*)
			if command -v tmux >/dev/null && command -v notify-send >/dev/null && [[ -n "${DESKTOP_SESSION}" ]]; then
				# libnotify "toaster" popup
				tmux new -d "sleep $((${minutes}*60)); notify-send POMODORO \"${message}\" --urgency=critical"
			elif command -v leave >/dev/null; then
				leave "+${minutes}"
			else
				printf "Error: unsupported platform\n"
				return 1
			fi
			;;
	esac
	unset -f usage
}

# poweroff() + reboot() with molly-guard
if [[ "${OS}" == 'OpenBSD' ]] || [[ -r "/etc/alpine-release" ]]; then
	poweroff() {
		stty -echo
		printf 'Please enter the name of the machine to power off: '
		read -r MACHINE_NAME
		stty echo
		printf '\n'
	
		if [[ "${HOSTNAME}" == "${MACHINE_NAME}" ]]; then
			if [[ "${OS}" == 'OpenBSD' ]]; then
				doas /sbin/shutdown -p now
			elif [[ -r "/etc/alpine-release" ]]; then
				doas /sbin/poweroff
			fi
		else
			printf "\n\nWrong hostname. Refusing to power off '%s'...\n\n" "${HOSTNAME}"
			return 1
		fi
	}
fi
reboot() {
	stty -echo
	printf 'Please enter the name of the machine to reboot: '
	read -r MACHINE_NAME
	stty echo
	printf '\n'

	if [[ "${HOSTNAME}" == "${MACHINE_NAME}" ]]; then
		doas /sbin/reboot
	else
		printf "\n\nWrong hostname. Refusing to reboot '%s'...\n\n" "${HOSTNAME}"
		return 1
	fi
}

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
		printf "usage:\n\tpwgen [INT]\n" && return 1
	fi
}

# rename() files
rename() {
	usage() {
		printf "usage:\n\trename [-nv] 'REGEX' filename(s)\n"
	}

	while getopts ":hnVv" option; do
		case "${option}" in
			h) usage && return 0 ;;
			n) local noop=1 ;;
			V) printf "rename() ksh function defined in ~/.kshrc\n" && return 0 ;;
			v) local verbose=1 ;;
			*) usage && return 1 ;;
		esac
	done

	# verify the passed regex is recognised by sed(1)
	if echo test_string | sed -E "${1}" >/dev/null 2>&1; then
		local regex="${1}"
		shift
	else
		printf "ERROR: sed(1) doesn't recognise extended regex '%s'.\n" "${1}" && return 1
	fi

	# verify input file(s) exist
	if [[ -z "${@}" ]]; then
		usage
		return 1
	fi
	if ! /bin/ls -- "${@}" >/dev/null 2>&1; then
		printf "ERROR: unable to stat file(s) '%s'.\n" "${@}" && return 1
	fi

	# batch rename
	/bin/ls -- "${@}" | while read -r oldname; do
		local newname="$(echo "${oldname}" | sed -E "${regex}")"

		# sanity checks
		if echo "${oldname}" | grep -F '/' >/dev/null 2>&1; then
			printf "WARNING: source file contains directory path character '/', skipping '%s'\n" "${oldname}"
			continue
		elif echo "${newname}" | grep -F '/' >/dev/null 2>&1; then
			printf "WARNING: destination file contains directory path character '/', skipping '%s'\n" "${newname}"
			continue
		elif [[ "${newname}" == "${oldname}" ]]; then
			continue
		elif [[ -r "${newname}" ]]; then
			printf "WARNING: destination file '%s' already exists, skipping.\n" "${newname}"
			continue
		fi

		# perform the rename
		if [[ "${noop}" == '1' ]]; then
			printf "WOULD MOVE: %s -> %s\n" "${oldname}" "${newname}"
		elif [[ "${verbose}" == '1' ]]; then
			/bin/mv -v -- "${oldname}" "${newname}"
		else
			/bin/mv -- "${oldname}" "${newname}"
		fi
	done
	unset -f usage
}

# rwhence() realpath + whence
rwhence() {
	if [[ "${#}" == '1' ]]; then
		local cmd="$(command -v "${1}")"
		if [[ -z "${cmd}" ]]; then
			printf "'%s' not found\n" "${1}" >&2
			return 1
		elif [[ -f "${cmd}" ]]; then
			realpath "${cmd}"
		else
			printf "'%s' is a function\n" "${1}" >&2
			return 1
		fi
	else
		printf "usage:\n\trwhence COMMAND\n" >&2
		return 1
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

# st() git repo status
st() {
	git status --branch --porcelain 2>/dev/null || got st 2>/dev/null || (printf "error: '%s' is not a git repo\n" "${PWD}"; return 1)
}

# sysinfo() system profiler
sysinfo() {
	scale() {
		printf "%s\n" "${1}" | awk -v CONVFMT='%.1f' '{ split( "K M G T E" , v ); s=1; while( $1>1024 ){ $1/=1024; s++ } print $1 v[s] }'
	}
	local arch="$(uname -m)"
	case "${OS}" in
		Linux)
			local distro="$(awk -F'"' '/PRETTY_NAME/ {print $2}' /etc/os-release 2>/dev/null)"
			if [[ -z "${distro}" ]]; then
				local distro='Linux'
			fi
			local kernel="$(echo "$(echo "${arch}" | sed 's/x86_64/amd64/'): $(uname -r | awk -F'-' '{print $1}')")"
			local cpu="$(echo "$(grep -c "^processor" /proc/cpuinfo)"cpu: "$(grep '^model name' /proc/cpuinfo | tail -n1 | awk -F': ' '{print $NF}' | tr -s " ")")"
			local uptime="$(awk -F'.' '{print $1}' /proc/uptime)"
			local meminfo="$(cat /proc/meminfo)"
			local memtot="$(echo "${meminfo}" | awk '/^MemTotal:/ {print $2}')"
			local memused="$(($(echo "${meminfo}" | awk '/^MemTotal:/ {print $2}') - $(echo "${meminfo}" | awk '/^Buffers:/ {print $2}') - $(echo "${meminfo}" | awk '/^Cached:/ {print $2}') - $(echo "${meminfo}" | awk '/^SReclaimable:/ {print $2}') - $(echo "${meminfo}" | awk '/^MemFree:/ {print $2}') - ($(echo "${meminfo}" | awk '/^HugePages_Free:/ {print $2}') * $(echo "${meminfo}" | awk '/^Hugepagesize:/ {print $2}'))))"
			local loadavg="$(cut -d' ' -f1-3 /proc/loadavg)"
			if [[ -r /sys/class/thermal/thermal_zone0/temp ]]; then
				local temperature="$(($(cat /sys/class/thermal/thermal_zone*/temp | sort -nr | head -n1) / 1000))"
			fi
			;;
		OpenBSD)
			local distro="$(sysctl -n kern.version | awk 'NR==1 {print $1, $2}')"
			local kernel="$(echo "${arch}: $(sysctl -n kern.version | awk 'NR==1 {print $NF, $6, $7}')")"
			local cpu="$(echo "$(sysctl -n hw.ncpuonline)"cpu: "$(sysctl -n hw.model)")"
			local uptime="$(($(date +%s) - $(sysctl -n kern.boottime)))"
			local memtot="$(($(sysctl -n hw.physmem)/1024))"
			local memused="$(($(vmstat -s | awk '/pages active$/ {print $1}') * $(sysctl -n hw.pagesize) / 1024))"
			local loadavg="$(sysctl -n vm.loadavg)"
			local temperature="$(sysctl -n hw.sensors.acpitz0.temp0 2>/dev/null | awk -F'.' '{print $1}')"
			;;
		*)
			local distro="${OS}"
			local kernel="${arch}: unknown"
			local cpu='unknown'
			local uptime='0'
			local memtot='0'
			local memused='0'
			local loadavg='unknown'
			;;
	esac

	if [[ "$((${uptime}/86400))" != '0' ]]; then
		local uptime_int="$((${uptime}/86400))"
		local uptime_unit='days(s)'
	elif [[ "$((${uptime}/3600))" != '0' ]]; then
		local uptime_int="$((${uptime}/3600))"
		local uptime_unit='hour(s)'
	elif [[ "$((${uptime}/60))" != '0' ]]; then
		local uptime_int="$((${uptime}/60))"
		local uptime_unit='minute(s)'
	else
		local uptime_int="${uptime}"
		local uptime_unit='seconds'
	fi

	if [[ -z "${temperature}" ]]; then
		local temperature='unknown '
	fi

	printf "os\t%s\n\
kernel\t%s\n\
uptime\t%s %s\n\
memory\t%s / %s\n\
load\t%s (%sºC)\n\
cpu\t%s\n" "${distro}" "${kernel}" "${uptime_int}" "${uptime_unit}" "$(scale ${memused})" "$(scale ${memtot})" "${loadavg}" "${temperature}" "${cpu}"
	unset -f scale
}

# thesaurus() synonym lookup
thesaurus() {
	if [[ $# -eq 1 ]]; then
		printf "D moby-thesaurus %s\nQ\n" "${1}" | nc dict.org 2628 | grep -Ev "^(150|220|221|250|\.)"
	else
		printf "usage:\n\tthesaurus WORD\n"
		return 1
	fi
}

# whattimeisitin() time zone query
whattimeisitin() {
	if [[ "${#}" == '0' ]]; then
		printf 'usage:\n\twhattimeisitin CITY\n'
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

### fix ssh agent forwarding workstation->jumpbox
if [[ "${HOSTNAME}" == "${SSH_JUMPBOX}" ]] && [[ -z "${DESKTOP_SESSION}" ]] && [[ -z "${XRDP_SESSION}" ]] && echo "${SSH_AUTH_SOCK}" | grep -E "^/tmp/ssh-.*/agent\." >/dev/null 2>&1; then
	if [[ -w "${HOME}" ]] && [[ -S "${SSH_AUTH_SOCK}" ]] && [[ "${SSH_AUTH_SOCK}" != "$(realpath "${SSH_AUTH_SOCK_PATH}" 2>/dev/null)" ]]; then
		/bin/ln -sf "${SSH_AUTH_SOCK}" "${SSH_AUTH_SOCK_PATH}"
	fi
	export SSH_AUTH_SOCK="${SSH_AUTH_SOCK_PATH}"
fi
