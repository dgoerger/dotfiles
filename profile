# .profile
if [[ "${SHELL}" == "/bin/bash" ]] || [[ "${SHELL}" == "/usr/bin/bash" ]] || [[ "${SHELL}" == "/bin/sh" ]]; then
  if [ -f ~/.bashrc ]; then
    source ~/.bashrc
  fi
fi
