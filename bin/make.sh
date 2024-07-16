#!/bin/ksh -
set -Cfuo pipefail

usage() {
	printf "usage:\n\tmake [check|dotfiles|install]\n\n"
}

if [[ "${#}" == '1' ]]; then
	TARGET="${1}"; readonly TARGET
else
	usage
	exit 1
fi

OS="$(uname)"; readonly OS

# initialize
CHROMIUM=''
CHROMIUM_DST='/etc/chromium/policies/managed/policy.json'; readonly CHROMIUM_DST
CHROMIUM_SRC='sysconfs/chromium.json'; readonly CHROMIUM_SRC
DAILY_SUMMARY_SRC='bin/daily_summary.py'; readonly DAILY_SUMMARY_SRC
DAILY_SUMMARY_DST='/usr/local/libexec/daily_summary.py'; readonly DAILY_SUMMARY_DST
DNSBLOCK_DST='/usr/local/sbin/dnsblock'; readonly DNSBLOCK_DST
DNSBLOCK_SRC='bin/dnsblock.sh'; readonly DNSBLOCK_SRC
DOAS=''
DOAS_DST='/etc/doas.conf'; readonly DOAS_DST
DOAS_SRC='sysconfs/doas.conf'; readonly DOAS_SRC
FIREFOX=''
FIREFOX_DST=''
FIREFOX_SRC='sysconfs/firefox.json'; readonly FIREFOX_SRC
FONTCONFIG=''
FONTCONFIG_DST='/etc/fonts/local.conf'; readonly FONTCONFIG_DST
FONTCONFIG_SRC='sysconfs/fontconfig.xml'; readonly FONTCONFIG_SRC
GERRIT_UPLOADER_DST='/usr/local/libexec/gerrit_uploader.sh'; readonly GERRIT_UPLOADER_DST
GERRIT_UPLOADER_SRC='bin/gerrit_uploader.sh'; readonly GERRIT_UPLOADER_SRC
KERNEL_BACKUP_DST='/usr/local/sbin/kernel_backup'; readonly KERNEL_BACKUP_DST
KERNEL_BACKUP_SRC='bin/kernel_backup.sh'; readonly KERNEL_BACKUP_SRC
MANUALS_COMPLETION_DST='/usr/local/sbin/manuals_tab_completion'; readonly MANUALS_COMPLETION_DST
MANUALS_COMPLETION_SRC='bin/manuals_tab_completion.sh'; readonly MANUALS_COMPLETION_SRC
NTPD_DST='/etc/ntpd.conf'; readonly NTPD_DST
NTPD_SRC='sysconfs/ntpd.conf'; readonly NTPD_SRC
OBSD_SYSCTL_DST='/etc/sysctl.conf'; readonly OBSD_SYSCTL_DST
OBSD_SYSCTL_SRC='sysconfs/sysctl.conf'; readonly OBSD_SYSCTL_SRC
PF_BLOCKLIST_DST='/usr/local/sbin/pf_blocklist'; readonly PF_BLOCKLIST_DST
PF_BLOCKLIST_SRC='bin/pf_blocklist.sh'; readonly PF_BLOCKLIST_SRC
SWAY=''
SYSSTATS_DST='/usr/local/sbin/sysstats.sh'; readonly SYSSTATS_DST
SYSSTATS_SRC='bin/sysstats.sh'; readonly SYSSTATS_SRC
WSCONSCTL_DST='/etc/wsconsctl.conf'; readonly WSCONSCTL_DST
WSCONSCTL_SRC='sysconfs/wsconsctl.conf'; readonly WSCONSCTL_SRC
XENODM=''
XENODM_DST='/etc/X11/xenodm/Xsetup_0'; readonly XENODM_DST
XENODM_SRC='sysconfs/Xsetup'

# check whether state applies to this host
if [[ -d '/etc/chromium/policies/managed' ]]; then
	CHROMIUM=1; readonly CHROMIUM
fi

if command -v doas >/dev/null 2>&1; then
	DOAS=1; readonly DOAS
fi

if [[ -d '/usr/local/lib/firefox/distribution' ]]; then
	FIREFOX=1; readonly FIREFOX
	FIREFOX_DST='/usr/local/lib/firefox/distribution/policies.json'; readonly FIREFOX_DST
elif [[ -d '/usr/lib64/firefox/distribution' ]]; then
	FIREFOX=1; readonly FIREFOX
	FIREFOX_DST='/usr/lib64/firefox/distribution/policies.json'; readonly FIREFOX_DST
fi

if [[ -d '/etc/fonts' ]]; then
	FONTCONFIG=1; readonly FONTCONFIG
fi

if pgrep -f '/usr/local/bin/sway' >/dev/null 2>&1; then
	SWAY=1; readonly SWAY
elif pgrep -f '/usr/X11R6/bin/xenodm' >/dev/null 2>&1; then
	XENODM=1; readonly XENODM
fi

# do the thing
case "${TARGET}" in
	-h|--help|help)
		usage
		exit 0
		;;
	check)
		if [[ -n "${CHROMIUM}" ]]; then
			diff -u "${CHROMIUM_DST}" "${CHROMIUM_SRC}"
		fi
		diff -u "${DNSBLOCK_DST}" "${DNSBLOCK_SRC}"
		if [[ -n "${DOAS}" ]]; then
			diff -u "${DOAS_DST}" "${DOAS_SRC}"
		fi
		if [[ -n "${FIREFOX}" ]]; then
			diff -u "${FIREFOX_DST}" "${FIREFOX_SRC}"
		fi
		if [[ -n "${FONTCONFIG}" ]]; then
			diff -u "${FONTCONFIG_DST}" "${FONTCONFIG_SRC}"
		fi
		diff -u "${GERRIT_UPLOADER_DST}" "${GERRIT_UPLOADER_SRC}"
		if [[ "${OS}" == 'OpenBSD' ]]; then
			diff -u "${DAILY_SUMMARY_DST}" "${DAILY_SUMMARY_SRC}"
			diff -u "${KERNEL_BACKUP_DST}" "${KERNEL_BACKUP_SRC}"
			diff -u "${MANUALS_COMPLETION_DST}" "${MANUALS_COMPLETION_SRC}"
			diff -u "${NTPD_DST}" "${NTPD_SRC}"
			diff -u "${OBSD_SYSCTL_DST}" "${OBSD_SYSCTL_SRC}"
			diff -u "${PF_BLOCKLIST_DST}" "${PF_BLOCKLIST_SRC}"
			diff -u "${SYSSTATS_DST}" "${SYSSTATS_SRC}"
			diff -u "${WSCONSCTL_DST}" "${WSCONSCTL_SRC}"
		fi
		if [[ -n "${XENODM}" ]]; then
			diff -u "${XENODM_DST}" "${XENODM_SRC}"
		fi
		;;
	dotfiles)
		diff -u ~/.alacritty.toml alacritty.toml
		diff -u ~/.gitconfig gitconfig
		if [[ "${SHELL}" == '/bin/ksh' ]]; then
			diff -u ~/.kshrc kshrc
			diff -u ~/.profile profile
		elif [[ "${SHELL}" == '/bin/zsh' ]]; then
			diff -u ~/.zshrc zshrc
		fi
		if command -v lynx >/dev/null 2>&1; then
			diff -u ~/.lynxrc lynxrc
		fi
		if command -v newsboat >/dev/null 2>&1; then
			diff -u ~/.newsboat/config newsboat_config
		fi
		diff -u ~/.config/nvim/init.lua nvim.lua
		diff -u ~/.pythonrc pythonrc
		diff -u ~/.tmux.conf tmux.conf
		if [[ "${OS}" == 'Linux' ]]; then
			diff -u ~/.bashrc bashrc
		elif [[ "${OS}" == 'OpenBSD' ]]; then
			diff -u ~/.exrc exrc
			diff -u ~/.mailcap mailcap
			diff -u ~/.mg mg
			if [[ -n "${SWAY}" ]]; then
				diff -u ~/.config/sway/config sway_config
			elif [[ -n "${XENODM}" ]]; then
				diff -u ~/.Xresources Xresources
				diff -u ~/.cwmrc cwmrc
				diff -u ~/.config/mpv/mpv.conf mpv.conf
				diff -u ~/.xscreensaver xscreensaver
				diff -u ~/.xsession xsession
			fi
		fi
		;;
	install)
		if [[ "$(id -u)" != '0' ]]; then
			printf "EPERM: must be run as root\n"
			exit 1
		fi
		if [[ -n "${CHROMIUM}" ]]; then
			# hacks to work around missing/non-standard 'install -[C|b|v]' flags
			# .. OpenBSD lacks '-v', and Alpine/busybox lacks all three
			if ! cmp -s "${CHROMIUM_SRC}" "${CHROMIUM_DST}" 2>/dev/null; then
				cp -p "${CHROMIUM_DST}" "${CHROMIUM_DST}.old"
				install -pm 0444 -o root -g bin "${CHROMIUM_SRC}" "${CHROMIUM_DST}"
				printf "install: %s -> %s\n" "${CHROMIUM_SRC}" "${CHROMIUM_DST}"
			fi
		fi
		if ! cmp -s "${DNSBLOCK_SRC}" "${DNSBLOCK_DST}" 2>/dev/null; then
			cp -p "${DNSBLOCK_DST}" "${DNSBLOCK_DST}.old"
			install -pm 0544 -o root -g bin "${DNSBLOCK_SRC}" "${DNSBLOCK_DST}"
			printf "install: %s -> %s\n" "${DNSBLOCK_SRC}" "${DNSBLOCK_DST}"
		fi
		if [[ -n "${DOAS}" ]]; then
			if ! cmp -s "${DOAS_SRC}" "${DOAS_DST}" 2>/dev/null; then
				cp -p "${DOAS_DST}" "${DOAS_DST}.old"
				install -pm 0444 -o root -g bin "${DOAS_SRC}" "${DOAS_DST}"
				printf "install: %s -> %s\n" "${DOAS_SRC}" "${DOAS_DST}"
			fi
		fi
		if [[ -n "${FIREFOX}" ]]; then
			if ! cmp -s "${FIREFOX_SRC}" "${FIREFOX_DST}" 2>/dev/null; then
				cp -p "${FIREFOX_DST}" "${FIREFOX_DST}.old"
				install -pm 0444 -o root -g bin "${FIREFOX_SRC}" "${FIREFOX_DST}"
				printf "install: %s -> %s\n" "${FIREFOX_SRC}" "${FIREFOX_DST}"
			fi
		fi
		if [[ -n "${FONTCONFIG}" ]]; then
			if ! cmp -s "${FONTCONFIG_SRC}" "${FONTCONFIG_DST}" 2>/dev/null; then
				cp -p "${FONTCONFIG_DST}" "${FONTCONFIG_DST}.old"
				install -pm 0444 -o root -g bin "${FONTCONFIG_SRC}" "${FONTCONFIG_DST}"
				printf "install: %s -> %s\n" "${FONTCONFIG_SRC}" "${FONTCONFIG_DST}"
			fi
		fi
		if ! cmp -s "${GERRIT_UPLOADER_SRC}" "${GERRIT_UPLOADER_DST}" 2>/dev/null; then
			cp -p "${GERRIT_UPLOADER_DST}" "${GERRIT_UPLOADER_DST}.old"
			install -pm 0445 -o root -g bin "${GERRIT_UPLOADER_SRC}" "${GERRIT_UPLOADER_DST}"
			printf "install: %s -> %s\n" "${GERRIT_UPLOADER_SRC}" "${GERRIT_UPLOADER_DST}"
		fi
		if [[ "${OS}" == 'OpenBSD' ]]; then
			if ! cmp -s "${DAILY_SUMMARY_SRC}" "${DAILY_SUMMARY_DST}" 2>/dev/null; then
				install -Cbm 0445 -o root -g bin "${DAILY_SUMMARY_SRC}" "${DAILY_SUMMARY_DST}"
				printf "install: %s -> %s\n" "${DAILY_SUMMARY_SRC}" "${DAILY_SUMMARY_DST}"
			fi
			if ! cmp -s "${KERNEL_BACKUP_SRC}" "${KERNEL_BACKUP_DST}" 2>/dev/null; then
				install -Cbm 0544 -o root -g bin "${KERNEL_BACKUP_SRC}" "${KERNEL_BACKUP_DST}"
				printf "install: %s -> %s\n" "${KERNEL_BACKUP_SRC}" "${KERNEL_BACKUP_DST}"
			fi
			if ! cmp -s "${MANUALS_COMPLETION_SRC}" "${MANUALS_COMPLETION_DST}" 2>/dev/null; then
				install -Cbm 0544 -o root -g bin "${MANUALS_COMPLETION_SRC}" "${MANUALS_COMPLETION_DST}"
				printf "install: %s -> %s\n" "${MANUALS_COMPLETION_SRC}" "${MANUALS_COMPLETION_DST}"
			fi
			if ! cmp -s "${NTPD_SRC}" "${NTPD_DST}" 2>/dev/null; then
				install -Cbm 0444 -o root -g bin "${NTPD_SRC}" "${NTPD_DST}"
				printf "install: %s -> %s\n" "${NTPD_SRC}" "${NTPD_DST}"
			fi
			if ! cmp -s "${OBSD_SYSCTL_SRC}" "${OBSD_SYSCTL_DST}" 2>/dev/null; then
				install -Cbm 0444 -o root -g bin "${OBSD_SYSCTL_SRC}" "${OBSD_SYSCTL_DST}"
				printf "install: %s -> %s\n" "${OBSD_SYSCTL_SRC}" "${OBSD_SYSCTL_DST}"
			fi
			if ! cmp -s "${PF_BLOCKLIST_SRC}" "${PF_BLOCKLIST_DST}" 2>/dev/null; then
				install -Cbm 0544 -o root -g bin "${PF_BLOCKLIST_SRC}" "${PF_BLOCKLIST_DST}"
				printf "install: %s -> %s\n" "${PF_BLOCKLIST_SRC}" "${PF_BLOCKLIST_DST}"
			fi
			if ! cmp -s "${SYSSTATS_SRC}" "${SYSSTATS_DST}" 2>/dev/null; then
				install -Cbm 0544 -o root -g bin "${SYSSTATS_SRC}" "${SYSSTATS_DST}"
				printf "install: %s -> %s\n" "${SYSSTATS_SRC}" "${SYSSTATS_DST}"
			fi
			if ! cmp -s "${WSCONSCTL_SRC}" "${WSCONSCTL_DST}" 2>/dev/null; then
				install -Cbm 0444 -o root -g bin "${WSCONSCTL_SRC}" "${WSCONSCTL_DST}"
				printf "install: %s -> %s\n" "${WSCONSCTL_SRC}" "${WSCONSCTL_DST}"
			fi
		fi
		if [[ -n "${XENODM}" ]]; then
			if ! cmp -s "${XENODM_SRC}" "${XENODM_DST}" 2>/dev/null; then
				install -Cbm 0555 -o root -g bin "${XENODM_SRC}" "${XENODM_DST}"
				printf "install: %s -> %s\n" "${XENODM_SRC}" "${XENODM_DST}"
			fi
		fi
		;;
	*)
		usage
		exit 1
		;;
esac
