# ~/.profile

### all operating systems and shells
## PATH
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/games:/usr/local/bin

## terminal settings
# fix backspace on old TERMs
#stty erase '^?' echoe
# SIGINFO: see signal(3)
stty status ^T 2>/dev/null
umask 077


## environment variables
unset ENV
export BROWSER=lynx
export GIT_AUTHOR_EMAIL="${LOGNAME}@users.noreply.github.com"
export GIT_AUTHOR_NAME="$(getent passwd "${LOGNAME}" | cut -d: -f5 | cut -d, -f1)"
export GIT_COMMITTER_EMAIL=${GIT_AUTHOR_EMAIL}
export GIT_COMMITTER_NAME=${GIT_AUTHOR_NAME}
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
export TZ='US/Eastern'
export VISUAL=vi


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
alias fetch='ftp -Vo'
alias free='top | grep -E "^Memory"'
if command -v kpcli >/dev/null; then
	alias kpcli='kpcli --histfile=/dev/null --readonly'
fi
alias l='ls -1F'
alias la='ls -aFhl'
alias larth='ls -aFhlrt'
alias less='less -iLMR'
alias listening='fstat -n | grep internet'
alias ll='ls -Fhl'
alias ls='ls -F'
alias mtop='top -o res'
alias mv='mv -i'
if command -v newsboat >/dev/null; then
	alias news='newsboat -q'
fi
if command -v nnn >/dev/null; then
	alias nnn='nnn -AdeHoR'
fi
alias pscpu='ps -Awwu'
alias psjob='ps -Awwo user,pid,ppid,pri,nice,stat,tt,wchan,time,command'
alias psmem='ps -Awwv'
if command -v python3 >/dev/null; then
	alias py=python3
fi
alias rm='rm -i'
alias sha512='sha512 -q'
alias stat='stat -x'
alias tm='tmux new-session -A -s tm'
if command -v nvim >/dev/null; then
	# prefer neovim > vim if available
	alias vi=nvim
	alias vim=nvim
	alias vimdiff='nvim -d -c "color blue" --'
fi
alias view='less -iLMR'
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
if [[ -z "${SSH_AUTH_SOCK}" ]] || [[ -n "$(echo "${SSH_AUTH_SOCK}" | grep -E "^/run/user/$(id -u)/keyring/ssh$")" ]]; then
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


### OS-specific overrides
if [[ "$(uname)" == "Linux" ]]; then
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
	export PS1="${HOSTNAME}$ "
	export QUOTING_STYLE=literal
	unset LS_COLORS

	# aliases
	if command -v atop >/dev/null; then
		alias atop='atop -fx'
	fi
	alias bc='bc -ql'
	if [[ -r /etc/alpine-release ]]; then
		alias checkupdates='apk list -u'
	elif [[ -r /etc/debian_version ]]; then
		alias checkupdates='apt list --upgradeable'
	elif [[ -r /etc/redhat-release ]]; then
		alias checkupdates='yum -q check-update'
	fi
	alias doas=/usr/bin/sudo #mostly-compatible
	alias fetch='curl -Lso'
	alias free='free -h'
	if command -v tnftp >/dev/null; then
		# BSD ftp has support for wget-like functionality
		alias ftp=tnftp
	fi
	alias l='ls -1F --color=never'
	alias la='ls -aFhl --color=never'
	alias larth='ls -aFhlrt --color=never'
	# linux doesn't have fstat
	alias listening='ss -lntu'
	alias ll='ls -Fhl --color=never'
	alias ls='ls -F --color=never'
	alias man='man --nh --nj'
	alias mtop='top -s -o "RES"'
	alias pscpu='ps -Awwo user,pid,pcpu,pmem,vsz,rss,tname,stat,start_time,cputime,command --sort -pcpu,-vsz,-pmem,-rss'
	alias psjob='ps -Awwo user,pid,ppid,pri,nice,stat,tname,wchan,cputime,command --sort ppid,pid'
	alias psmem='ps -Awwo user,pid,stat,cputime,majflt,vsz,rss,trs,pcpu,pmem,command --sort -vsz,-rss,-pcpu'
	if ! command -v pstree >/dev/null; then
		alias pstree='ps -HAwwo user,pid,pcpu,pmem,vsz,rss,tname,stat,start_time,cputime,command'
	fi
	if command -v sar >/dev/null; then
		alias sarcpu='sar -qu'
		alias sarmem='sar -BHrS'
		alias sarnet='sar -n DEV'
		alias sarnfs='sar -n NFS'
	fi
	if command -v sshfs >/dev/null; then
		alias sshfs='sshfs -o no_readahead,idmap=user'
	fi
	unalias sha512
	function sha512 {
		sha512sum --tag "${1}" | awk '{print $NF}'
	}
	unalias stat
	systat() {
		printf "%s\n\n" "systat(1) isn't available for Linux. Maybe sar(1) or atop(1)?"
	}
	alias vi='vi -nu NONE --noplugin'
	alias top='top -s'
	if command -v tree >/dev/null; then
		alias tree='tree -N'
	fi
	if [[ -z "$(whence whence 2>/dev/null)" ]]; then
		# whence exists in ksh, but not in bash
		alias whence='(alias; declare -f) | /usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot'
	fi

elif [[ "$(uname)" == 'NetBSD' ]]; then
	export CC=clang
	export CXX=clang++
	export MANPATH=${HOME}/man:/usr/pkg/man:/usr/pkg/share/man:/usr/share/man:/usr/pkg/X11R7/man:/usr/local/man
	export PATH=${HOME}/bin:${PATH}

	alias pkgsrc='lynx "https://ftp.netbsd.org/pub/pkgsrc/packages/NetBSD/x86_64/$(uname -r)/All/"'
	unalias sha512
	function sha512 {
		cksum -a SHA512 "${1}" | awk '{print $NF}'
	}

elif [[ "$(uname)" == 'OpenBSD' ]]; then
	# aliases
	apropos() {
		# search all sections of the manual by default
		/usr/bin/man -k any="${1}"
	}
	if [[ -r /etc/installurl ]]; then
		if [[ -z "$(sysctl kern.version | grep '\-current')" ]]; then
			checkupdates() {
				# on -stable, check if there are available syspatches
				local _patchfile="$(mktemp /tmp/checkupdates.XXXXXXXXXX)"
				ftp -VMo "${_patchfile}" "$(cat /etc/installurl)/syspatch/$(uname -r)/$(uname -m)/SHA256"
				if [[ "$(echo "(syspatch$(/bin/ls -hrt /var/syspatch/ | tail -n 1).tgz)")" != "$(tail -n 1 "${_patchfile}" | awk '{print $2}')" ]]; then
					printf "%s\n" "Updates are available via syspatch(8)."
				else
					printf "%s\n" "System is up-to-date."
				fi
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
			}
		fi
	fi
fi


# ksh tab completions
if [[ "${0}" == '-ksh' ]] || [[ "${0}" == '-oksh' ]] || [[ "${0}" == 'ksh' ]]; then
	# OpenBSD/NetBSD compatibility
	export HOST_LIST=$(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts | sort -u)

	set -A complete_diff_1 -- -u
	set -A complete_dig_1 -- ${HOST_LIST}
	set -A complete_git_1 -- add bisect blame checkout clone commit diff log mv pull push rebase reset revert rm stash status submodule
	if command -v got >/dev/null; then
		set -A complete_got_1 -- add backout blame branch checkout cherrypick commit diff histedit import init integrate log rebase ref rm revert stage status tag tree unstage update
	fi
	set -A complete_host_1 -- ${HOST_LIST}
	if command -v ifconfig >/dev/null; then
		set -A complete_ifconfig_1 -- $(ifconfig | awk -F':' '/^[a-z]/ {print $1}')
	fi
	set -A complete_kill_1 -- -9 -HUP -INFO -KILL -TERM
	set -A complete_kpcli_1 -- --kdb
	if [[ -r /usr/local/etc/manuals.list ]]; then
		set -A complete_man_1 -- $(cat /usr/local/etc/manuals.list)
	fi
	if command -v mtr >/dev/null; then
		set -A complete_mtr_1 -- -wbz
		set -A complete_mtr_2 -- ${HOST_LIST}
	fi
	if command -v ncdu >/dev/null; then
		set -A complete_ncdu_1 -- -ex -rex
	fi
	set -A complete_openssl_1 -- ciphers s_client verify version x509
	set -A complete_openssl_2 -- -h
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
	set -A complete_rsync_1 -- -prtv
	set -A complete_rsync_2 -- ${HOST_LIST}
	set -A complete_rsync_3 -- ${HOST_LIST}
	set -A complete_scp_1 -- -p
	set -A complete_scp_2 -- ${HOST_LIST}
	set -A complete_scp_3 -- ${HOST_LIST}
	set -A complete_sftp_1 -- -p
	set -A complete_sftp_2 -- ${HOST_LIST}
	set -A complete_search_1 -- alpine arxiv centos cve debian fedora github_issues mandragonflybsd manfreebsd manillumos manlinux manminix mannetbsd manopenbsd mathworld mbug nws rfc rhbz thesaurus wayback webster wikipedia wiktionary
	set -A complete_ssh_1 -- ${HOST_LIST}
	set -A complete_systat_1 -- buckets cpu ifstat iostat malloc mbufs netstat nfsclient nfsserver pf pigs pool pcache queues rules sensors states swap vmstat uvm
	set -A complete_telnet_1 -- ${HOST_LIST}
	set -A complete_telnet_2 -- 22 25 80
	if command -v toot >/dev/null; then
		set -A complete_toot_1 -- block follow instance mute notifications post tui unblock unfollow unmute upload whoami whois
		set -A complete_toot_2 -- --help
	fi
	set -A complete_tmux_1 -- attach list-commands list-sessions list-windows new-session new-window source
	set -A complete_traceroute_1 -- ${HOST_LIST}
	set -A complete_traceroute6_1 -- ${HOST_LIST}
fi


### functions
# arxifetch() download papers from arXiv by document ID
arxifetch() {
	if [[ $# -eq 1 ]]; then
		local title="$(fetch - "https://arxiv.org/abs/${1}" | awk -F'"' '/meta\ name.*citation_title/ {print $4}')"
	        if [[ ! -z "${title}" ]]; then
	                fetch "${title} - ${1}.pdf" "https://arxiv.org/pdf/${1}" && \
	                        printf "Downloaded file '%s - %s.pdf'.\n" "${title}" "${1}"
	        else
	                printf "ERROR: arXiv document ID '%s' not found.\n" "${1}" && return 1
	        fi
	else
	        printf 'usage:\n    arxifetch ARXIV_ID\n' && return 1
	fi
}

# certcheck() verify tls certificates
certcheck() {
	# set default options
	local EXPIRY_THRESHOLD_WARNING=15
	local EXPIRY_THRESHOLD_CRITICAL=5
	local PORT=443

	# set FQDN (required)
	if [[ -n "${1}" ]]; then
		if getent hosts "${1}" >/dev/null 2>&1; then
			local FQDN="${1}"
		elif host "${1}" >/dev/null 2>&1; then
			# fallback - macOS doesn't have getent(1)
			local FQDN="${1}"
		else
			printf "Cannot find %s in DNS.\n" "${1}" && return 1
		fi
	else
		printf 'Please specify an FQDN to query.\n' && return 1
	fi

	# set PORT (optional)
	if [[ -n "${2}" ]]; then
		case ${2} in
			''|*[!0-9]*) printf 'port must be an integer\n' && return 1 ;;
			*) local PORT="${2}" ;;
		esac
	fi

	# set protocol-specific flags as necessary
	if [[ "${PORT}" == '25' ]] || [[ "${PORT}" == '587' ]]; then
		# protocol == starttls (smtp/25, smtp-submission/587)
		local PROTOCOL_FLAGS="-starttls smtp"
	elif [[ "${PORT}" == '5222' ]] || [[ "${PORT}" == '5269' ]]; then
		# protocol == starttls (xmpp-client/5222, xmpp-server/5269)
		local PROTOCOL_FLAGS="-starttls xmpp"
	else
		# protocol == tls+sni (https/443, smtps/465, ldaps/636, xmpps/5223, https-tomcat/8443, etc)
		local PROTOCOL_FLAGS="-servername ${FQDN}"
	fi

	# query cert status
	local QUERY="$(echo Q | openssl s_client ${PROTOCOL_FLAGS} -connect "${FQDN}:${PORT}" 2>/dev/null)"
	local CERTIFICATE_AUTHORITY="$(echo "${QUERY}" | sed 's/\ =\ /=/g' | awk -F'CN=' '/^issuer=/ {print $2}')"
	local ROOT_AUTHORITY="$(echo "${QUERY}" | grep -E '^Certificate chain$' -A4 | tail -n1 | sed 's/\ =\ /=/g' | awk -F'CN=' '/i:/ {print $2}')"
	local TLS_PROTOCOL="$(echo "${QUERY}" | awk '/Protocol  :/ {print $NF}')"
	local TLS_CIPHER="$(echo "${QUERY}" | awk '/Cipher    :/ {print $NF}')"
	local EXPIRY_DATE="$(echo "${QUERY}" | openssl x509 -noout -enddate 2>/dev/null | awk -F'=' '/notAfter/ {print $2}')"
	local CHAIN_OF_TRUST_STATUS="$(echo "${QUERY}" | awk '/Verify return code:/ {print $4}')"
	# note - this doesn't take wildcard certificates into consideration
	local VALID_FOR_DOMAIN="$(echo "${QUERY}" | openssl x509 -text | grep "DNS:${FQDN}")"

	# error if we can't find a certificate
	if [[ -z "${EXPIRY_DATE}" ]]; then
		echo "UNKNOWN: certificate ${FQDN}:${PORT} is unreachable" && return 1
	fi

	# print certificate authority info
	if [[ -z "${ROOT_AUTHORITY}" ]]; then
		local ROOT_AUTHORITY='??'
	fi
	echo "Issuer: ${CERTIFICATE_AUTHORITY} -> ${ROOT_AUTHORITY}"

	# error if the chain-of-trust can't be verified
	if [[ "${CHAIN_OF_TRUST_STATUS}" != '0' ]]; then
		echo "Status: CRITICAL - ${FQDN}:${PORT} cannot be determined to be authentic (chain-of-trust)" && return 1
	fi

	# calculate the number of days to expiry
	if [[ "$(uname)" == 'Linux' ]]; then
		local SECONDS_TO_EXPIRY="$(echo "$(date --date="${EXPIRY_DATE}" +%s) - $(date +%s)" | bc -l)"
	else
		local SECONDS_TO_EXPIRY="$(echo "$(date -jf "%b %e %H:%M:%S %Y %Z" "${EXPIRY_DATE}" +%s) - $(date +%s)" | bc -l)"
	fi
	local DAYS_TO_EXPIRY="$(echo "scale=0; ${SECONDS_TO_EXPIRY} / 86400" | bc -l)"

	# set status based on expiry thresholds
	if [[ "${SECONDS_TO_EXPIRY}" -lt '0' ]]; then
		local STATUS="CRITICAL - ${FQDN}:${PORT} is already expired"
	elif [[ "${DAYS_TO_EXPIRY}" -le "${EXPIRY_THRESHOLD_CRITICAL}" ]]; then
		local STATUS="CRITICAL - ${FQDN}:${PORT} expires in ${DAYS_TO_EXPIRY} day(s)"
	elif [[ "${DAYS_TO_EXPIRY}" -le "${EXPIRY_THRESHOLD_WARNING}" ]]; then
		local STATUS="WARNING - ${FQDN}:${PORT} expires in ${DAYS_TO_EXPIRY} day(s)"
	else
		local STATUS="OK - ${FQDN}:${PORT} expires in ${DAYS_TO_EXPIRY} day(s)"
	fi

	echo "Cipher: ${TLS_CIPHER} (${TLS_PROTOCOL})"
	echo "Expiry: ${EXPIRY_DATE}"
	if [[ -n "${VALID_FOR_DOMAIN}" ]]; then
		echo "Domain: OK - certificate is valid for ${FQDN}"
	else
		echo "Domain: WARNING - certificate is NOT explicitly valid for ${FQDN} (is it a wildcard?)"
	fi
	echo "Status: ${STATUS}"
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
alias colors=colours

# def() define a word
if command -v wn >/dev/null && command -v pandoc >/dev/null; then
	def() {
		if [[ $# -eq 1 ]]; then
			if [[ -n "$(wn "${1}" -over)" ]]; then
				wn "${1}" -over | pandoc -t plain -
			elif command -v wtf >/dev/null; then
				wtf "${1}"
			else
				printf "No definition found for %s.\n" "${1}"
			fi
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

# dvd() and radio()
if command -v mpv >/dev/null; then
	audiocd() {
		if [[ "$(uname)" == 'OpenBSD' ]] && [[ ! -r /dev/rcd0c ]]; then
			printf 'Cannot read /dev/rcd0c. Try: chgrp wheel /dev/rcd0c\n' && return 1
		fi
		if [[ $# -eq 0 ]]; then
			mpv cdda://
		else
			printf 'usage:\n    audiocd\n' && return 1
		fi
	}
	dvd() {
		if [[ "$(uname)" == 'OpenBSD' ]] && [[ ! -r /dev/rcd0c ]]; then
			printf 'Cannot read /dev/rcd0c. Try: chgrp wheel /dev/rcd0c\n' && return 1
		fi
		if [[ $# -eq 1 ]]; then
			case ${1} in
				''|*[!0-9]*) printf "Error: \${1} must be an integer.\n" && return 1 ;;
				*) mpv --audio-normalize-downmix=yes "dvdread://${1}" ;;
			esac
		else
			printf 'usage:\n    dvd INT, where INT is the chapter number.\n' && return 1
		fi
	}
	radio() {
		if [[ $# -eq 1 ]]; then
			case ${1} in
				## via https://www.radio-browser.info
				# Canada: Radio-Canada Montréal (français)
				ici) mpv "http://2QMTL0.akacast.akamaistream.net/7/953/177387/v1/rc.akacast.akamaistream.net/2QMTL0" ;;
				ici-musique) mpv "http://7qmtl0.akacast.akamaistream.net/7/445/177407/v1/rc.akacast.akamaistream.net/7QMTL0" ;;
				# USA: Prairie Public Radio (North Dakota)
				kdsu) mpv "https://18433.live.streamtheworld.com/KCNDHD3_SC" ;;
				# USA: Minnesota Public Radio
				mpr) mpv "https://current.stream.publicradio.org/kcmp.mp3" ;;
				# Deutschland: Queerlive
				queerlive) mpv "https://queerlive.stream.laut.fm/queerlive" ;;
				# USA: NPR WGBH Boston
				wgbh) mpv "http://audio.wgbh.org:8000" ;;
				# USA: Monroe independent radio station
				wmnr) mpv "http://amber.streamguys.com:6050/live.m3u" ;;
				# USA: NPR WNYC New York City
				wnyc) mpv "http://fm939.wnyc.org/wnycfm" ;;
				*) printf 'Error: unknown stream\n' && return 1 ;;
			esac
		else
			printf 'usage:\n    radio STREAM\n' && return 1
		fi
	}
fi

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
		</dev/urandom tr -cd '[:alnum:]' | fold -w 30 | head -n1
	elif [[ $# == 1 ]]; then
		case ${1} in
			''|*[!0-9]*) echo "Error: \${1} must be an integer." && return 1 ;;
			*) </dev/urandom tr -cd '[:alnum:]' | fold -w "${1}" | head -n1
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
	if ! /bin/ls "${@}" >/dev/null 2>&1; then
		printf "ERROR: unable to stat file(s) '%s'.\n" "${@}" && return 1
	fi

	# batch rename
	/bin/ls "${@}" | while read -r oldname; do
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
#			s/ /+/g;
			s/ /%20/g;
			s/(/%28/g;
			s/)/%29/g;
			s/"/%22/g;
			s/#/%23/g;
			s/\$/%24/g;
			s/&/%26/g;
			s/,/%2C/g;
#			s/\./%2E/g;
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
			lynx "https://packages.debian.org/"
		else
			lynx "https://packages.debian.org/search?keywords=${query}&searchon=names&suite=stable&section=all"
		fi
	elif [[ "${1}" == 'fedora' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://koji.fedoraproject.org/koji"
		else
			lynx "https://koji.fedoraproject.org/koji/search?match=glob&type=package&terms=${query}"
		fi
	elif [[ "${1}" == 'github_issues' ]]; then
		shift
		project="${1}"
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://github.com/${project}"
		else
			lynx "https://github.com/${project}/search?o=desc&q=${query}&s=created&type=Issues"
		fi
	elif [[ "${1}" == 'gutenberg' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://www.gutenberg.org/"
		else
			lynx "https://www.gutenberg.org/catalog/world/results?&title=${query}"
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
	elif [[ "${1}" == 'manminix' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://man.minix3.org/cgi-bin/man.cgi"
		else
			lynx "https://man.minix3.org/cgi-bin/man.cgi?query=${query}&apropos=0&sektion=0&manpath=Minix&arch=default&format=html"
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
	elif [[ "${1}" == 'mathworld' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "http://mathworld.wolfram.com/"
		else
			lynx "http://mathworld.wolfram.com/search/?query=${query}&x=0&y=0"
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
	elif [[ "${1}" == 'wayback' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://www.archive.org/"
		else
			lynx "https://www.archive.org/searchresults.php?mediatype=web&Submit=Take+Me+Back&search=${query}"
		fi
	elif [[ "${1}" == 'webster' ]]; then
		shift
		local query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://www.merriam-webster.com/dictionary.htm"
		else
			lynx "https://www.merriam-webster.com/dictionary/${query}"
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

# shacompare() sha512 file comparison
shacompare() {
	if [[ $# == 2 ]] && [[ -r "${1}" ]] && [[ -r "${2}" ]]; then
		local file1="$(sha512 "${1}")"
		local file2="$(sha512 "${2}")"

		if [[ "${file1}" == "${file2}" ]]; then
			printf 'The two files are sha512-identical.\n'
		else
			printf 'The two files are NOT sha512-identical.\n'
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
		local memory_query="$(echo "$(echo "$(sysctl -n hw.memsize)" / 1024^2 | bc) $(vm_stat | grep ' active' | awk '{ print $3 }' | sed 's/\.//')")"
	elif [[ "$(uname)" == 'Linux' ]]; then
		local cpu="$(echo "$(lscpu | awk '/^CPU\(s\):/ {print $NF}')"cpu: "$(grep '^model name' /proc/cpuinfo | uniq | awk -F': ' '{print $NF}' | tr -s " ")")"
		local disk_query="$(/bin/df -h -x aufs -x tmpfs -x overlay -x devtmpfs -x udf -x nfs -x cifs --total 2>/dev/null | awk '{print $2, $3, $5}' | tail -n1)"
		local distro="$(grep PRETTY_NAME /etc/os-release 2>/dev/null | awk -F'"' '{print $2}')"
		if [[ -z "${distro}" ]]; then
			local distro='Linux'
		fi
		local gpu="$(nvidia-smi -q 2>/dev/null | awk -F':' '/Product Name/ {gsub(/: /,":"); print "Nvidia", $2}' | sed ':a;N;$!ba;s/\n/, /g')"
		if [[ -z "${gpu}" ]]; then
			local gpu="$(glxinfo 2>/dev/null | awk '/OpenGL renderer string/ { sub(/OpenGL renderer string: /,""); print }')"
		fi
		local host="$(echo "$(cat /sys/devices/virtual/dmi/id/sys_vendor) $(cat /sys/devices/virtual/dmi/id/product_name)")"
		local kernel="$(uname -r)"
		local memory_query="$(/usr/bin/free -b | grep -E "^Mem:" | awk '{ print $2,$3 }')"
	elif [[ "$(uname)" == 'NetBSD' ]]; then
		local cpu="$(echo "$(sysctl -n hw.ncpuonline)"cpu: "$(sysctl -n machdep.cpu_brand | tr -s " ")")"
		local disk_query="$(/bin/df -Pk 2>/dev/null | awk '/^\// {total+=$2; used+=$3}END{printf("%.1fGiB %.1fGiB %d%%\n", total/1048576, used/1048576, used*100/total)}')"
		local distro='NetBSD'
		local host="$(echo "$(sysctl -n machdep.dmi.system-vendor) $(sysctl -n machdep.dmi.system-product)")"
		local kernel="$(uname -rm)"
		local memory_query="$(echo "$(sysctl -n hw.pagesize) $(sysctl -n hw.usermem64) $(vmstat -s | awk '/pages active$/ {print $1}')" | awk '{ print $2, $1 * $3 }')"
	elif [[ "$(uname)" == 'OpenBSD' ]]; then
		local cpu="$(echo "$(sysctl -n hw.ncpuonline)"cpu: "$(sysctl -n hw.model)")"
		local disk_query="$(/bin/df -Pk 2>/dev/null | awk '/^\// {total+=$2; used+=$3}END{printf("%.1fGiB %.1fGiB %d%%\n", total/1048576, used/1048576, used*100/total)}')"
		local distro='OpenBSD'
		local gpu="$(/usr/X11R6/bin/glxinfo 2>/dev/null | awk '/OpenGL renderer string/ { sub(/OpenGL renderer string: /,""); print }')"
		local host="$(echo "$(sysctl -n hw.vendor) $(sysctl -n hw.product)")"
		local kernel="$(uname -rvm)"
		local memory_query="$(echo "$(sysctl -n hw.pagesize) $(sysctl -n hw.usermem) $(vmstat -s | awk '/pages active$/ {print $1}')" | awk '{ print $2, $1 * $3 }')"
	else
		local cpu='unknown'
		local distro="$(uname)"
		local host='unknown'
		local kernel="$(uname -rm)"
		local memory_query='1 0'
	fi
	local disk_total="$(echo "${disk_query}" | awk '{print $1}')"
	local disk_used="$(echo "${disk_query}" | awk '{print $2}')"
	local disk_percent_used="$(echo "${disk_query}" | awk '{print $3}')"
	local memory_percent_used=$(echo "${memory_query}" | awk '{print $2/$1*100}' | awk -F'.' '{print $1}')
	local memory_total=$(echo "${memory_query}" | awk '{print $1/1024^2}' | awk -F'.' '{print $1}')
	local memory_used=$(echo "${memory_query}" | awk '{print $2/1024^2}' | awk -F'.' '{print $1}')
	local uptime="$(uptime | awk '{print $3, $4}' | sed 's/\,//g')"
	if [[ "$(echo "${uptime}" | awk -F':' '{print $1}')" != "${uptime}" ]]; then
		local uptime="$(echo "${uptime}" | awk -F':' '{print $1}') hour(s)"
	fi
	printf "\n\t%s@%s\n\n" "${LOGNAME}" "${HOSTNAME}"
	printf "OS:\t\t%s\n" "${distro}"
	printf "Kernel:\t\t%s\n" "${kernel}"
	printf "Uptime:\t\t%s\n" "${uptime}"
	printf "Shell:\t\t%s\n" "${SHELL}"
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

# touchmode() touch + set the mode of a new file
touchmode() {
	if [[ $# == 2 ]]; then
		case "${1}" in
			''|*[!0-9]*) printf 'MODE must be an integer\n' && return 1 ;;
			*) local MODE="${1}" ;;
		esac
		if [[ -f "${2}" ]]; then
			printf 'File already exists.\n' && return 1
		else
			if [[ "$(uname)" == 'Linux' ]]; then
				install -Z -C -m "${MODE}" /dev/null "${2}"
			else
				install -C -m "${MODE}" /dev/null "${2}"
			fi
		fi
	else
		printf 'usage:\n    touchmode MODE /path/to/file\n' && return 1
	fi
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

### source profile-local files
if [[ "${SHELL}" != '/bin/ash' ]]; then
	set -o emacs
fi
if [[ -r "${HOME}/.profile.local" ]]; then
	. "${HOME}/.profile.local"
fi

### got(1)
if command -v got >/dev/null; then
	export GOT_AUTHOR="${GIT_AUTHOR_NAME} <${GIT_AUTHOR_EMAIL}>"
fi
