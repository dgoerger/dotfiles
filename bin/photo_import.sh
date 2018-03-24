#!/bin/ksh
#
# This script will search recursively for exif metadata in supported files
# within the current directory, and copy images to ${MOVETO}/\$YYYY/\$MM/\$DD.


# supported filetypes
FILETYPES="jpg jpeg"

# require exiv2
if [[ ! -x "$(which exiv2 2>/dev/null)" ]]; then
  echo "Abort! Depends on exiv2."
  return 1
fi

# what does the thing and wins the points
import_photo() {
  MOVETO="${HOME}/Pictures"

  # fetch EXIF data
  DATETIME="$(exiv2 -pt -qK Exif.Photo.DateTimeOriginal "${1}" 2>/dev/null | awk '{print $(NF-1)}' | sed 's/\:/\//g' | sort -u)"

  # sanity checks re datetime data
  if [[ -z "${DATETIME}" ]]; then
    echo "${1}: Abort! DateTime not found" | tee -a "${MOVETO}/$(date +%Y%m%d-%H%M)_import_failure.log"
    return 1
  fi
  if [[ "$(echo "${DATETIME}" | wc -l)" -ne 1 ]]; then
    echo "${1}: Abort! File has more than one DateTime declaration" | tee -a "${MOVETO}/$(date +%Y%m%d-%H%M)_import_failure.log"
    return 1
  fi
  if [[ "$(uname)" == 'OpenBSD' ]]; then
    if ! date -j "$(echo "${DATETIME}/0000" | sed 's/\///g')" >/dev/null 2>&1; then
      echo "${1}: Abort! /bin/date doesn't recognise the detected DateTime as a valid date" | tee -a "${MOVETO}/$(date +%Y%m%d-%H%M)_import_failure.log"
      return 1
    fi
  elif [[ "$(uname)" == 'Linux' ]]; then
    if ! date --date="$(echo "${DATETIME}" | sed 's/\///g')" >/dev/null 2>&1; then
      echo "${1}: Abort! /bin/date doesn't recognise the detected DateTime as a valid date" | tee -a "${MOVETO}/$(date +%Y%m%d-%H%M)_import_failure.log"
      return 1
    fi
  fi

  # lowercase the filename
  FILENAME="$(echo "${1}" | awk -F"/" '{print $NF}' | tr '[:upper:]' '[:lower:]')"

  # copy the file into place
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
  find . -type f -iname "*.${x}" | while read -r jpeg; do import_photo "${jpeg}"; done
done
