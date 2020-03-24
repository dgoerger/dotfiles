# ~/.zshrc, see zshmodules(1) and zshoptions(1)

# load tab-completion
autoload -Uz compinit
if [[ ! -d "${HOME}/.cache/zsh" ]]; then
	mkdir -p "${HOME}/.cache/zsh"
fi
compinit -d "${HOME}/.cache/zsh/zcompdump-${ZSH_VERSION}"

# history opts
set -o hist_expire_dups_first
set -o hist_ignore_dups
set -o hist_reduce_blanks
set -o inc_append_history

if [[ -r ${HOME}/.profile ]]; then
	. ${HOME}/.profile
fi
