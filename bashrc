# ~/.bashrc

export PS1="\h$ "

if [[ -r ${HOME}/.profile ]]; then
	. ${HOME}/.profile
fi
