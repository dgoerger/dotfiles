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
export GIT_AUTHOR_EMAIL="$(getent passwd "${LOGNAME}" | cut -d: -f1)@users.noreply.github.com"
export GIT_AUTHOR_NAME="$(getent passwd "${LOGNAME}" | cut -d: -f5 | cut -d, -f1)"
export GIT_COMMITTER_EMAIL=${GIT_AUTHOR_EMAIL}
export GIT_COMMITTER_NAME=${GIT_AUTHOR_NAME}
if [[ -x "$(/usr/bin/which got 2>/dev/null)" ]]; then
	export GOT_AUTHOR="${GIT_AUTHOR_NAME} <${GIT_AUTHOR_EMAIL}>"
fi
export HISTCONTROL=ignoredups
export HISTFILE=${HOME}/.history
export HISTSIZE=20736
export HOSTNAME=$(hostname -s)
export LANG="en_CA.UTF-8"
export LC_ALL="en_CA.UTF-8"
export LESSSECURE=1
export LESSHISTFILE=-
if [[ -r "${HOME}/.lynxrc" ]]; then
	export LYNX_CFG="${HOME}/.lynxrc"
	alias lynx='COLUMNS=80 lynx -useragent "Mozilla/5.0 (Windows NT 10.0; rv:68.0) Gecko/20100101 Firefox/68.0" 2>/dev/null'
	if [[ -r "${HOME}/.elynxrc" ]]; then
		alias elynx='COLUMNS=80 lynx -cfg=~/.elynxrc -useragent "Mozilla/5.0 (Windows NT 10.0; rv:68.0) Gecko/20100101 Firefox/68.0" 2>/dev/null'
	fi
fi
#export MUTTRC=${path_to_mutt_gpg}
if [[ -r "${HOME}/.pythonrc" ]]; then
	export PYTHONSTARTUP="${HOME}/.pythonrc"
fi
export TZ='US/Eastern'
export VISUAL=vi


## aliases
if [[ -x "$(/usr/bin/which abook 2>/dev/null)" ]]; then
	alias abook='abook --config ${HOME}/.abookrc --datafile ${HOME}/.addresses'
fi
alias bc='bc -l'
if [[ -x "$(/usr/bin/which cabal 2>/dev/null)" ]] && [[ -d /usr/local/cabal/build ]] && [[ -w /usr/local/cabal/build ]]; then
	alias cabal='env TMPDIR=/usr/local/cabal/build/ cabal'
fi
alias cal='cal -m'
if [[ -x "$(/usr/bin/which calendar 2>/dev/null)" ]]; then
	alias calendar='calendar -f ${HOME}/.calendar'
fi
alias cp='cp -i'
if [[ -x "$(/usr/bin/which cvs 2>/dev/null)" ]]; then
	alias cvsup='cvs -q up -PdA'
fi
alias df='df -h'
alias free='top | grep -E "^Memory"'
if [[ -x "$(/usr/bin/which kpcli 2>/dev/null)" ]]; then
	alias kpcli='kpcli --histfile=/dev/null --readonly'
fi
alias l='ls -1F'
alias la='ls -Flah'
alias larth='ls -Flarth'
alias less='less -MR'
alias listening='fstat -n | grep internet'
alias ll='ls -lhF'
alias ls='ls -F'
alias mv='mv -i'
if [[ -x "$(/usr/bin/which newsboat 2>/dev/null)" ]]; then
	alias news='newsboat -q'
fi
if [[ -x "$(/usr/bin/which python3 2>/dev/null)" ]]; then
	alias py=python3
	alias python=python3
fi
alias rm='rm -i'
if [[ -x "$(/usr/bin/which openrsync 2>/dev/null)" ]]; then
	alias rsync=openrsync
fi
alias stat='stat -x'
alias tm='tmux new-session -A -s tm'
if [[ -x "$(/usr/bin/which nvim 2>/dev/null)" ]]; then
	# prefer neovim > vim if available
	alias vi=nvim
	alias view='nvim --cmd "let no_plugin_maps = 1" -c "runtime! macros/less.vim" -m -M -R -n --'
	alias vim=nvim
	alias vimdiff='nvim -d -c "color blue" --'
else
	alias view='less -MR'
	alias vim=vi
fi
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
	export HTOPRC=/dev/null
	export MANWIDTH=80
	if [[ -L "/bin" ]]; then
		# some Linux have /bin -> /usr/bin
		export PATH=/usr/local/bin:/bin:/sbin
	fi
	export QUOTING_STYLE=literal
	unset LS_COLORS

	# aliases
	if [[ -x "$(/usr/bin/which bc 2>/dev/null)" ]]; then
		alias bc='bc -ql'
	fi
	alias df='df -h -xtmpfs -xdevtmpfs'
	alias doas=/usr/bin/sudo #mostly-compatible
	alias free='free -h'
	if [[ -x "$(/usr/bin/which tnftp 2>/dev/null)" ]]; then
		# BSD ftp has support for wget-like functionality
		alias ftp=tnftp
	fi
	alias l='ls -1F --color=never'
	alias la='ls -Flah --color=never'
	alias larth='ls -Flarth --color=never'
	# linux doesn't have fstat
	if [[ -x "$(/usr/bin/which netstat 2>/dev/null)" ]]; then
		alias listening='netstat -launt | grep LISTEN'
	else
		alias listening='ss -tuna'
	fi
	alias ll='ls -lhF --color=never'
	alias ls='ls -F --color=never'
	alias mtop='top -s -o "%MEM"'
	# linux ps lists kernel threads amongst procs.. deselect those
	# .. it's a bit hacky, but seems to work and is much more readable
	# ref: https://unix.stackexchange.com/a/78585
	alias psaux='ps auw --ppid 2 -p 2 --deselect'
	if [[ -x "$(/usr/bin/which sshfs 2>/dev/null)" ]]; then
		alias sshfs='sshfs -o no_readahead,idmap=user'
	fi
	alias sha256='sha256sum --tag'
	alias sha512='sha512sum --tag'
	unalias stat
	alias top='top -s'
	if [[ -x "$(/usr/bin/which tree 2>/dev/null)" ]]; then
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
	export PATH=${HOME}/bin:/usr/pkg/bin:$PATH

	alias pkgsrc='lynx "https://ftp.netbsd.org/pub/pkgsrc/packages/NetBSD/x86_64/$(uname -r)/All/"'
	alias py=/usr/pkg/bin/python3
	alias python=/usr/pkg/bin/python3
	alias sha512='cksum -a SHA512'
	alias vi=/usr/pkg/bin/vim

elif [[ "$(uname)" == 'OpenBSD' ]]; then
	# aliases
	apropos() {
		# search all sections of the manual by default
		/usr/bin/man -k any="${1}"
	}
	if [[ -r /etc/installurl ]]; then
		# shortcut to check snapshot availability - especially useful during release/freeze
		# .. or package updates to -stable
		if [[ -z "$(sysctl kern.version | grep '\-current')" ]]; then
			alias checksnaps='/usr/local/bin/lynx "$(cat /etc/installurl)/$(uname -r)/packages-stable/$(uname -m)"'
		else
			alias checksnaps='/usr/local/bin/lynx "$(cat /etc/installurl)/snapshots/$(uname -m)"'
		fi
	fi
fi


# ksh tab completions
if [[ "${0}" == '-ksh' ]] || [[ "${0}" == '-oksh' ]] || [[ "${0}" == 'ksh' ]]; then
	# OpenBSD/NetBSD compatibility
	export HOST_LIST=$(awk '/^[a-z]/ {split($1,a,","); print a[1]}' ~/.ssh/known_hosts)

	set -A complete_diff_1 -- -u
	set -A complete_dig_1 -- ${HOST_LIST}
	set -A complete_git_1 -- add bisect blame checkout clone commit diff log mv pull push rebase reset revert rm stash status submodule
	if [[ -x "$(/usr/bin/which got 2>/dev/null)" ]]; then
		set -A complete_got_1 -- add backout blame branch checkout cherrypick commit diff histedit import init integrate log rebase ref rm revert stage status tag tree unstage update
	fi
	set -A complete_host_1 -- ${HOST_LIST}
	if [[ -x "$(/usr/bin/which ifconfig 2>/dev/null)" ]]; then
		set -A complete_ifconfig_1 -- $(ifconfig | awk -F':' '/^[a-z]/ {print $1}')
	fi
	set -A complete_kill_1 -- -9 -HUP -INFO -KILL -TERM
	set -A complete_kpcli_1 -- --kdb
	if [[ -r /usr/local/etc/manuals.list ]]; then
		set -A complete_man_1 -- $(cat /usr/local/etc/manuals.list)
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
	if [[ -x "$(/usr/bin/which ncdu 2>/dev/null)" ]]; then
		set -A complete_ncdu_1 -- -ex -rex
	fi
	if [[ -x "$(/usr/bin/which nmap 2>/dev/null)" ]]; then
		set -A complete_nmap_1 -- ${HOST_LIST}
	fi
	set -A complete_openssl_1 -- ciphers s_client verify version x509
	set -A complete_openssl_2 -- -h
	set -A complete_ping_1 -- ${HOST_LIST}
	set -A complete_ping6_1 -- ${HOST_LIST}
	set -A complete_ps_1 -- -auxw
	if [[ "$(uname)" == 'OpenBSD' ]] && [[ -r /etc/rc.d ]]; then
		set -A complete_rcctl_1 -- disable enable get ls order set
		set -A complete_rcctl_2 -- $(rcctl ls all)
	fi
	if [[ -x "$(/usr/bin/which rmapi 2>/dev/null)" ]]; then
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
	set -A complete_sftp_3 -- ${HOST_LIST}
	set -A complete_search_1 -- alpine arxiv centos cve fedora mathworld mbug nws rfc rhbz thesaurus wayback webster wikipedia wiktionary
	set -A complete_ssh_1 -- ${HOST_LIST}
	set -A complete_telnet_1 -- ${HOST_LIST}
	set -A complete_telnet_2 -- 22 25 80
	if [[ -x "$(/usr/bin/which toot 2>&1)" ]]; then
		set -A complete_toot_1 -- block follow instance mute notifications post tui unblock unfollow unmute upload whoami whois
		set -A complete_toot_2 -- --help
	fi
	set -A complete_tmux_1 -- attach list-commands list-sessions list-windows new-session new-window source
	set -A complete_traceroute_1 -- ${HOST_LIST}
	set -A complete_traceroute6_1 -- ${HOST_LIST}
fi


### functions
# certcheck() verify tls certificates
certcheck() {
	# set default options
	EXPIRY_THRESHOLD_WARNING=15
	EXPIRY_THRESHOLD_CRITICAL=5
	PORT=443

	# set FQDN (required)
	if [[ -n "${1}" ]]; then
		if getent hosts "${1}" >/dev/null 2>&1; then
			FQDN="${1}"
		elif host "${1}" >/dev/null 2>&1; then
			# fallback - macOS doesn't have getent(1)
			FQDN="${1}"
		else
			echo "Cannot find ${1} in DNS." && return 1
		fi
	else
		echo "Please specify an FQDN to query." && return 1
	fi

	# set PORT (optional)
	if [[ -n "${2}" ]]; then
		case ${2} in
			''|*[!0-9]*) echo 'port must be an integer' && return 1 ;;
			*) PORT="${2}" ;;
		esac
	fi

	# set protocol-specific flags as necessary
	if [[ "${PORT}" == '25' ]] || [[ "${PORT}" == '587' ]]; then
		# protocol == starttls (smtp/25, smtp-submission/587)
		PROTOCOL_FLAGS="-starttls smtp"
	elif [[ "${PORT}" == '5222' ]] || [[ "${PORT}" == '5269' ]]; then
		# protocol == starttls (xmpp-client/5222, xmpp-server/5269)
		PROTOCOL_FLAGS="-starttls xmpp"
	else
		# protocol == tls+sni (https/443, smtps/465, ldaps/636, xmpps/5223, https-tomcat/8443, etc)
		PROTOCOL_FLAGS="-servername ${FQDN}"
	fi

	# query cert status
	QUERY="$(echo Q | openssl s_client ${PROTOCOL_FLAGS} -connect "${FQDN}:${PORT}" 2>/dev/null)"
	CERTIFICATE_AUTHORITY="$(echo "${QUERY}" | awk -F'CN=' '/^issuer=/ {print $2}')"
	ROOT_AUTHORITY="$(echo "${QUERY}" | grep -E '^Certificate chain$' -A4 | tail -n1 | awk -F'CN=' '/i:/ {print $2}')"
	TLS_PROTOCOL="$(echo "${QUERY}" | awk '/Protocol  :/ {print $NF}')"
	TLS_CIPHER="$(echo "${QUERY}" | awk '/Cipher    :/ {print $NF}')"
	EXPIRY_DATE="$(echo "${QUERY}" | openssl x509 -noout -enddate 2>/dev/null | awk -F'=' '/notAfter/ {print $2}')"
	CHAIN_OF_TRUST_STATUS="$(echo "${QUERY}" | awk '/Verify return code:/ {print $4}')"
	# note - this doesn't take wildcard certificates into consideration
	VALID_FOR_DOMAIN="$(echo "${QUERY}" | openssl x509 -text | grep "DNS:${FQDN}")"

	# error if we can't find a certificate
	if [[ -z "${EXPIRY_DATE}" ]]; then
		echo "UNKNOWN: certificate ${FQDN}:${PORT} is unreachable" && return 1
	fi

	# print certificate authority info
	if [[ -z "${ROOT_AUTHORITY}" ]]; then
		ROOT_AUTHORITY='??'
	fi
	echo "Issuer: ${CERTIFICATE_AUTHORITY} -> ${ROOT_AUTHORITY}"

	# error if the chain-of-trust can't be verified
	if [[ "${CHAIN_OF_TRUST_STATUS}" != '0' ]]; then
		echo "Status: CRITICAL - ${FQDN}:${PORT} cannot be determined to be authentic (chain-of-trust)" && return 1
	fi

	# calculate the number of days to expiry
	if [[ "$(uname)" == 'Linux' ]]; then
		SECONDS_TO_EXPIRY="$(echo "$(date --date="${EXPIRY_DATE}" +%s) - $(date +%s)" | bc -l)"
	else
		SECONDS_TO_EXPIRY="$(echo "$(date -jf "%b %e %H:%M:%S %Y %Z" "${EXPIRY_DATE}" +%s) - $(date +%s)" | bc -l)"
	fi
	DAYS_TO_EXPIRY="$(echo "scale=0; ${SECONDS_TO_EXPIRY} / 86400" | bc -l)"

	# set status based on expiry thresholds
	if [[ "${SECONDS_TO_EXPIRY}" -lt '0' ]]; then
		STATUS="CRITICAL - ${FQDN}:${PORT} is already expired"
	elif [[ "${DAYS_TO_EXPIRY}" -le "${EXPIRY_THRESHOLD_CRITICAL}" ]]; then
		STATUS="CRITICAL - ${FQDN}:${PORT} expires in ${DAYS_TO_EXPIRY} day(s)"
	elif [[ "${DAYS_TO_EXPIRY}" -le "${EXPIRY_THRESHOLD_WARNING}" ]]; then
		STATUS="WARNING - ${FQDN}:${PORT} expires in ${DAYS_TO_EXPIRY} day(s)"
	else
		STATUS="OK - ${FQDN}:${PORT} expires in ${DAYS_TO_EXPIRY} day(s)"
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
if [[ -x "$(/usr/bin/which wn 2>/dev/null)" ]] && [[ -x "$(/usr/bin/which pandoc 2>/dev/null)" ]]; then
	def() {
		if [[ $# -eq 1 ]]; then
			if [[ -n "$(wn "${1}" -over)" ]]; then
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

# diff() with syntax highlighting
diff() {
	# nota bene: [[ -t 1 ]] => "is output to stdout", for example, versus a pipe or a file
	if [[ -t 1 ]] && [[ "${#}" -eq 2 ]] && [[ -r "${1}" ]] && [[ -r "${2}" ]]; then
		/usr/bin/diff "${1}" "${2}" | awk '/^[1-9]/ {printf "\033[0;36m%s\033[0;0m\n", $0}
			/^</ {printf "\033[0;31m%s\033[0;0m\n", $0}
			/^>/ {printf "\033[0;32m%s\033[0;0m\n", $0}
			/^-/ {printf "\033[0;0m%s\n", $0}'
	elif [[ -t 1 ]] && [[ "${#}" -eq 3 ]] && [[ "${1}" == '-u' ]] && [[ -r "${2}" ]] && [[ -r "${3}" ]]; then
		/usr/bin/diff -u "${2}" "${3}" | awk '/^\@/ {printf "\033[0;36m%s\033[0;0m\n", $0}
			/^\-/ {printf "\033[0;31m%s\033[0;0m\n", $0}
			/^\+/ {printf "\033[0;32m%s\033[0;0m\n", $0}
			/^\ / {printf "\033[0;0m%s\033[0;0m\n", $0}'
	else
		/usr/bin/diff "$@"
	fi
}

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
				*) mpv --audio-normalize-downmix=yes "dvdread://${1}" ;;
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
				# USA: Monroe independent radio station
				wmnr) mpv "http://amber.streamguys.com:6050/live.m3u" ;;
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

# fd() find files and directories
fd() {
        if [[ "${#}" != '1' ]]; then
                echo -e "Usage:\n    fd FILENAME\n"
        else
                find . -iname "*${1}*"
        fi
}

# photo_import() import photos from an SD card
if [[ -x "$(/usr/bin/which exiv2 2>/dev/null)" ]]; then
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

# pomodoro() timer
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
		echo "Usage: pwgen [INT], where INT defaults to 30." && return 1
	fi
 }

# search() the web
search() {
	# try to guess preferred language from $LANG
	if [[ -n "${LANG}" ]]; then
		lang="$(echo "${LANG}" | cut -c1-2)"
	else
		lang='en'
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
		query="$(_escape_html "$@")"
		if [[ -z "{query}" ]]; then
			lynx "https://pkgs.alpinelinux.org/packages"
		else
			lynx "https://pkgs.alpinelinux.org/packages?name=${query}&branch=edge"
		fi
	elif [[ "${1}" == 'arxiv' ]]; then
		shift
		query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://arxiv.org/"
		else
			lynx "https://arxiv.org/search/?query=${query}&searchtype=all&source=header"
		fi
	elif [[ "${1}" == 'centos' ]]; then
		shift
		query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://koji.mbox.centos.org/koji/"
		else
			lynx "https://koji.mbox.centos.org/koji/search?match=glob&type=package&terms=${query}"
		fi
	elif [[ "${1}" == 'cve' ]]; then
		shift
		query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "http://cve.mitre.org"
		else
			lynx "http://cve.mitre.org/cgi-bin/cvename.cgi?name=${query}"
		fi
	elif [[ "${1}" == 'fedora' ]]; then
		shift
		query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://koji.fedoraproject.org/koji"
		else
			lynx "https://koji.fedoraproject.org/koji/search?match=glob&type=package&terms=${query}"
		fi
	elif [[ "${1}" == 'gutenberg' ]]; then
		shift
		query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://www.gutenberg.org/"
		else
			lynx "https://www.gutenberg.org/catalog/world/results?&title=${query}"
		fi
	elif [[ "${1}" == 'linux' ]]; then
		shift
		if [[ "$#" == '0' ]]; then
			lynx "https://linux.die.net/man/"
		elif [[ "$#" == '2' ]]; then
			lynx "https://linux.die.net/man/${1}/${2}"
		else
			echo -e 'usage:\n\n    search linux SECTION MANUAL' && return 1
		fi
	elif [[ "${1}" == 'mathworld' ]]; then
		shift
		query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "http://mathworld.wolfram.com/"
		else
			lynx "http://mathworld.wolfram.com/search/?query=${query}&x=0&y=0"
		fi
	elif [[ "${1}" == 'mbug' ]]; then
		shift
		query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://bugzilla.mozilla.org/"
		else
			lynx "https://bugzilla.mozilla.org/buglist.cgi?quicksearch=${query}"
		fi
	elif [[ "${1}" == 'nws' ]]; then
		shift
		query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://www.weather.gov/"
		else
			lynx "https://forecast.weather.gov/zipcity.php?inputstring=${query}&btnSearch=Go&unit=1"
		fi
	elif [[ "${1}" == 'rfc' ]]; then
		shift
		query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://www.ietf.org/standards/rfcs/"
		else
			lynx "https://tools.ietf.org/rfc/rfc${query}.txt"
		fi
	elif [[ "${1}" == 'rhbz' ]]; then
		shift
		query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://bugzilla.redhat.com/"
		else
			lynx "https://bugzilla.redhat.com/buglist.cgi?quicksearch=${query}"
		fi
	elif [[ "${1}" == 'thesaurus' ]]; then
		shift
		query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://en.oxforddictionaries.com/english-thesaurus"
		else
			lynx "https://en.oxforddictionaries.com/thesaurus/${query}"
		fi
	elif [[ "${1}" == 'wayback' ]]; then
		shift
		query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://www.archive.org/"
		else
			lynx "https://www.archive.org/searchresults.php?mediatype=web&Submit=Take+Me+Back&search=${query}"
		fi
	elif [[ "${1}" == 'webster' ]]; then
		shift
		query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://www.merriam-webster.com/dictionary.htm"
		else
			lynx "https://www.merriam-webster.com/dictionary/${query}"
		fi
	elif [[ "${1}" == 'wikipedia' ]]; then
		shift
		query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://${lang}.wikipedia.org/wiki/"
		else
			lynx "https://${lang}.wikipedia.org/wiki/index.php?search=${query}&go=Go"
		fi
	elif [[ "${1}" == 'wiktionary' ]]; then
		shift
		query="$(_escape_html "$@")"
		if [[ -z "${query}" ]]; then
			lynx "https://${lang}.wiktionary.org/wiki/"
		else
			lynx "https://${lang}.wiktionary.org/wiki/index.php?search=${query}&go=Go"
		fi
	else
		query="$(_escape_html "$@")"
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
		file1="$(sha512 "${1}" | awk '{print $NF}')"
		file2="$(sha512 "${2}" | awk '{print $NF}')"

		if [[ "${file1}" == "${file2}" ]]; then
			echo "The two files are sha512-identical."
		else
			echo "The two files are NOT sha512-identical."
		fi
	else
		echo -e 'Usage: shacompare FILE1 FILE2\n' && return 1
	fi
}

# sysinfo() system profiler
sysinfo() {
	if [[ "$(uname)" == 'Darwin' ]]; then
		cpu="$(sysctl -n machdep.cpu.brand_string)"
		disk_query="$(df -H /System/Volumes/Data 2>/dev/null | tail -n1 | awk '{print $2, $3, $5}')"
		distro='macOS'
		gpu="$(system_profiler SPDisplaysDataType | awk -F': ' '/^\ *Chipset Model:/ {print $2}' | awk '{ printf "%s / ", $0 }' | sed -e 's/\/ $//g')"
		host="$(sysctl -n hw.model)"
		kernel="$(uname -rm)"
		memory_query="$(echo "$(echo "$(sysctl -n hw.memsize)" / 1024^2 | bc) $(vm_stat | grep ' active' | awk '{ print $3 }' | sed 's/\.//')")"
	elif [[ "$(uname)" == 'Linux' ]]; then
		cpu="$(grep '^model name' /proc/cpuinfo | uniq | awk -F': ' '{print $NF}')"
		disk_query="$(/bin/df -h -x aufs -x tmpfs -x overlay -x devtmpfs -x udf -x nfs -x cifs --total 2>/dev/null | awk '{print $2, $3, $5}' | tail -n1)"
		distro="$(grep PRETTY_NAME /etc/os-release 2>/dev/null | awk -F'"' '{print $2}')"
		if [[ -z "${distro}" ]]; then
			distro='Linux'
		fi
		gpu="$(nvidia-smi -q 2>/dev/null | awk -F':' '/Product Name/ {gsub(/: /,":"); print "Nvidia", $2}' | sed ':a;N;$!ba;s/\n/, /g')"
		if [[ -z "${gpu}" ]]; then
			gpu="$(glxinfo 2>/dev/null | awk '/OpenGL renderer string/ { sub(/OpenGL renderer string: /,""); print }')"
		fi
		host="$(echo "$(cat /sys/devices/virtual/dmi/id/sys_vendor) $(cat /sys/devices/virtual/dmi/id/product_name)")"
		kernel="$(uname -r)"
		memory_query="$(/usr/bin/free -b | grep -E "^Mem:" | awk '{ print $2,$3 }')"
	elif [[ "$(uname)" == 'NetBSD' ]]; then
		cpu="$(sysctl -n machdep.cpu_brand)"
		disk_query="$(/bin/df -Pk 2>/dev/null | awk '/^\// {total+=$2; used+=$3}END{printf("%.1fGiB %.1fGiB %d%%\n", total/1048576, used/1048576, used*100/total)}')"
		distro='NetBSD'
		host="$(echo "$(sysctl -n machdep.dmi.system-vendor) $(sysctl -n machdep.dmi.system-product)")"
		kernel="$(uname -rm)"
		memory_query="$(echo "$(sysctl -n hw.pagesize) $(sysctl -n hw.usermem64) $(vmstat -s | awk '/pages active$/ {print $1}')" | awk '{ print $2, $1 * $3 }')"
	elif [[ "$(uname)" == 'OpenBSD' ]]; then
		cpu="$(sysctl -n hw.model)"
		disk_query="$(/bin/df -Pk 2>/dev/null | awk '/^\// {total+=$2; used+=$3}END{printf("%.1fGiB %.1fGiB %d%%\n", total/1048576, used/1048576, used*100/total)}')"
		distro='OpenBSD'
		gpu="$(/usr/X11R6/bin/glxinfo 2>/dev/null | awk '/OpenGL renderer string/ { sub(/OpenGL renderer string: /,""); print }')"
		host="$(echo "$(sysctl -n hw.vendor) $(sysctl -n hw.product)")"
		kernel="$(uname -rvm)"
		memory_query="$(echo "$(sysctl -n hw.pagesize) $(sysctl -n hw.usermem) $(vmstat -s | awk '/pages active$/ {print $1}')" | awk '{ print $2, $1 * $3 }')"
	else
		cpu='unknown'
		distro="$(uname)"
		host='unknown'
		kernel="$(uname -rm)"
		memory_query='1 0'
	fi
	disk_total="$(echo "${disk_query}" | awk '{print $1}')"
	disk_used="$(echo "${disk_query}" | awk '{print $2}')"
	disk_percent_used="$(echo "${disk_query}" | awk '{print $3}')"
	memory_percent_used=$(echo "${memory_query}" | awk '{print $2/$1*100}' | awk -F'.' '{print $1}')
	memory_total=$(echo "${memory_query}" | awk '{print $1/1024^2}' | awk -F'.' '{print $1}')
	memory_used=$(echo "${memory_query}" | awk '{print $2/1024^2}' | awk -F'.' '{print $1}')
	uptime="$(uptime | awk '{print $3, $4}' | sed 's/\,//g')"
	if [[ "$(echo ${uptime} | awk -F':' '{print $1}')" != "${uptime}" ]]; then
		uptime="$(echo ${uptime} | awk -F':' '{print $1}') hour(s)"
	fi
	printf "\n\t%s@%s\n\n" "${USER}" "${HOSTNAME}"
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
			''|*[!0-9]*) echo 'MODE must be an integer' && return 1 ;;
			*) MODE="${1}" ;;
		esac
		if [[ -f "${2}" ]]; then
			echo 'File already exists.' && return 1
		else
			if [[ "$(uname)" == 'Linux' ]]; then
				install -Z -C -m "${MODE}" /dev/null "${2}"
			else
				install -C -m "${MODE}" /dev/null "${2}"
			fi
		fi
	else
		echo -e 'usage:\n        touchmode MODE /path/to/file' && return 1
	fi
}

### source profile-local files
if [[ "${SHELL}" != '/bin/ash' ]]; then
	set -o emacs
fi
#if [[ -x "$(/usr/bin/which fortune 2>/dev/null)" ]]; then
#	fortune -a
#fi
if [[ -r "${HOME}/.profile.local" ]]; then
	. "${HOME}/.profile.local"
fi
