# ~/.zshrc, see zshmodules(1) and zshoptions(1)

# load tab-completion
autoload -Uz compinit
compinit -d ~/.cache/zsh/zcompdump-$ZSH_VERSION

# history opts
set -o hist_expire_dups_first
set -o hist_ignore_dups
set -o inc_append_history

if [[ -r ${HOME}/.profile ]]; then
  . ${HOME}/.profile
fi
