# .bashrc

if [[ -r ${HOME}/.profile ]]; then
  . ${HOME}/.profile
elif [[ -r /etc/bashrc ]]; then
  . /etc/bashrc
fi
