# ~/.zshrc, see zshmodules(1) and zshoptions(1)

## compat
set -o complete_aliases
set -o interactive_comments
set -o local_options
set -o no_auto_menu
set -o posix_identifiers
autoload -U select-word-style
select-word-style bash

## history
set -o hist_expire_dups_first
set -o hist_ignore_dups
set -o hist_reduce_blanks
set -o inc_append_history

## prompt
export PROMPT='%m%(!.#.$) '

## tab-completion
# disable fuzzy match
zstyle ':completion:*' accept-exact-dirs true
# case-sensitive
zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=* r:|=*'
# smaller 'cd' tab-completion array
zstyle ':completion:*:cd:*' tag-order local-directories
# enable cache
zstyle ':completion:*' use-cache yes
autoload -Uz compinit
compinit -i -D

## source shell-agnostic aliases and functions
if [[ -r ${HOME}/.kshrc ]]; then
	. ${HOME}/.kshrc
fi

if [[ -w "${HOME}" ]]; then
	if [[ -n "${HISTSIZE}" ]]; then
		export SAVEHIST="${HISTSIZE}"
	elif [[ -n "${HISTFILE}" ]]; then
		unset HISTFILE
	fi
fi
