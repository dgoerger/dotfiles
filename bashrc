# ~/.bashrc

export PS1="\h$ "

if [[ -r ${HOME}/.kshrc ]]; then
	. ${HOME}/.kshrc
fi
