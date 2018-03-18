#!/bin/ksh
#
# The script will search recursively for
# exif-supported filetypes in the current
# directory, and copy files to
# ${MOVETO}/\$YYYY/\$MM/\$DD

# TODO properly import other types
FILETYPES="jpg jpeg tif tiff"

# require exif
if [[ ! -x "$(which exif 2>/dev/null)" ]]; then
  echo "Abort! Depends on exif."
  exit 1
fi

import_photo() {
  MOVETO="${HOME}/Pictures"

  # fetch EXIF data
  DATETIME="$(exif -t 'DateTime' -m "${1}" 2>/dev/null | awk -F" " '{print $1}' | sed 's/\:/\//g' | sort -u)"

  # sanity checks re datetime data
  if [[ -z "${DATETIME}" ]]; then
    echo "${1}: Abort! DateTime not found" | tee --append "${MOVETO}/$(date +%Y%m%d-%H%M)_import_failure.log"
    exit 1;
  fi;
  if [[ "$(echo "${DATETIME}" | wc -l)" != "1" ]]; then
    echo "${1}: Abort! File has more than one DateTime declaration" | tee --append "${MOVETO}/$(date +%Y%m%d-%H%M)_import_failure.log"
    exit 1;
  fi

  # lowercase the filename
  FILENAME="$(echo "${1}" | awk -F"/" '{print $NF}' | tr '[:upper:]' '[:lower:]')"

  if [[ -n "${FILENAME}" ]]; then
    # copy is safer than move
    mkdir -p "${MOVETO}/${DATETIME}"
    if [[ ! -f "${MOVETO}/${DATETIME}/${FILENAME}" ]]; then
      cp -p "${1}" "${MOVETO}/${DATETIME}/${FILENAME}" && echo "Imported ${DATETIME}/${FILENAME}"
    fi
  fi
}

# main
for x in ${FILETYPES}; do
  # WARNING: 'typeset' is NOT posix,
  #          but works in bash and ksh
  find . -iname "*.${x}" -exec sh -c "
    $(typeset -f import_photo)"'
    import_photo "$@"' sh {} \;
done
