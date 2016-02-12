# .profile
# Get the aliases and functions
if [ "${SHELL}" == "/bin/bash" ]; then
  if [ -f ~/.bashrc ]; then
    source ~/.bashrc
  fi
fi

# load ssh-agent on desktops, not on servers
# ... checking for a display is usually sufficient
# note: if loaded in places you ssh *to*, your agent may not be forwardable
if [ -n "${DISPLAY}" ]; then
  export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
fi
