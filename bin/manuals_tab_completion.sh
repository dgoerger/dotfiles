#!/bin/ksh
# Precompute an array for ksh(1) tab-completion of man(1).
#
# Motivation:
#   - tab-completion of manuals is helpful
#   - recomputing the array for each new login shell is costly
#   - the list of manuals doesn't change frequently
#
# Limitations:
#   - the list of manuals doesn't update until the next cron(8) run
#   - many manuals in section 1 don't correspond with an executable
#     and are thus filtered out (e.g. perl* and git-*)
#   - X11 manuals are omitted
#   - sections 5 and 7 completions omit manuals from ports(7)
#   - sections 2, 3, 3p, 4, and 9 are omitted for brevity

TMPFILE="$(mktemp)"
CONFFILE="/usr/local/etc/manuals.list"

if [[ "$(uname)" == 'OpenBSD' ]]; then
  # why is section 1 filled with so much junk?
  man -M /usr/share/man:/usr/local/man -s 1 -k Nm~. | cut -d\( -f1 | tr -d , | while read -r COMMAND; do if [[ -x "$(/usr/bin/which "${COMMAND}" 2>/dev/null)" ]]; then echo "${COMMAND}"; fi; done >> "${TMPFILE}"
  #man -M /usr/share/man:/usr/local/man -s 2 -k Nm~. | cut -d\( -f1 | tr -d , >> "${TMPFILE}"
  #man -M /usr/share/man:/usr/local/man -s 3 -k Nm~. | cut -d\( -f1 | tr -d , >> "${TMPFILE}"
  #man -M /usr/share/man:/usr/local/man -s 3p -k Nm~. | cut -d\( -f1 | tr -d , >> "${TMPFILE}"
  #man -M /usr/share/man:/usr/local/man -s 4 -k Nm~. | cut -d\( -f1 | tr -d , >> "${TMPFILE}"
  man -M /usr/share/man -s 5 -k Nm~. | cut -d\( -f1 | tr -d , >> "${TMPFILE}"
  man -M /usr/share/man:/usr/local/man -s 6 -k Nm~. | cut -d\( -f1 | tr -d , >> "${TMPFILE}"
  man -M /usr/share/man -s 7 -k Nm~. | cut -d\( -f1 | tr -d , >> "${TMPFILE}"
  man -M /usr/share/man:/usr/local/man -s 8 -k Nm~. | cut -d\( -f1 | tr -d , >> "${TMPFILE}"
  #man -M /usr/share/man:/usr/local/man -s 9 -k Nm~. | cut -d\( -f1 | tr -d , >> "${TMPFILE}"
  cat "${TMPFILE}" | sort -u > "${CONFFILE}"
  chown root:wheel "${CONFFILE}"
  chmod 0444 "${CONFFILE}"
fi
