# .bashrc

if [[ -r ${HOME}/.env ]]; then
  . ${HOME}/.env
elif [[ -r /etc/bashrc ]]; then
  . /etc/bashrc
fi
