# ~/.bashrc

# quick exit for non-interactive shells
if [[ ${-} != *i* ]]; then return; fi

export PS1="\h$ "

if [[ -r ${HOME}/.kshrc ]]; then
	. ${HOME}/.kshrc
fi
