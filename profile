# .profile
if [[ "${SHELL}" == "/bin/bash" ]] || [[ "${SHELL}" == "/usr/bin/bash" ]]; then
  if [[ -f ~/.bashrc ]]; then
    source ~/.bashrc
  elif [ -f /etc/bashrc ]; then
    source /etc/bashrc
  fi
fi
