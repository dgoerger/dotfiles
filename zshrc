# ~/.zshrc, see zshmodules(1) and zshoptions(1)

## compat
set -o append_create
set -o bsd_echo
set -o complete_aliases
set -o interactive_comments
set -o ksh_arrays
set -o ksh_option_print
set -o local_options
set -o local_traps
set -o no_auto_menu
set -o null_glob
set -o posix_aliases
set -o posix_argzero
set -o posix_builtins
set -o posix_identifiers
set -o sh_word_split


## history
set -o hist_expire_dups_first
set -o hist_ignore_dups
set -o hist_reduce_blanks
set -o inc_append_history


## source shell-agnostic aliases and functions
if [[ -r ${HOME}/.profile ]]; then
	. ${HOME}/.profile
fi
