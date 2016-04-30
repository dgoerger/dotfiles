#!/bin/bash
###############################################
# adapted from: https://mikebeach.org/?p=4729 #
###############################################

# EXIF data is only present in jpeg and tiff
# generate import failure log for other types
# TODO: properly import other types
FILETYPES="jpg jpeg tif tiff gif bmp xcf ogg ogv webm mp4 mov"

# CHANGEME: destination folder
MOVETO="${HOME}/Pictures/"

# sanity check that $MOVETO exists
if [[ ! -d "${MOVETO}" ]]; then
  echo "Abort! Destination ${MOVETO} does not exist!"
  exit 1
fi

# print help/usage info
if [[ "${1}" == "-h" || "${1}" == "--help" || "${1}" == "--usage" ]]; then
  echo ""
  echo "Usage:"
  echo "  sh script"
  echo ""
  echo "The script will search recursively for"
  echo "filetypes: $(echo ${FILETYPES} | sed 's/\ /\,\ /g')"
  echo "in the current directory, and copy files"
  echo "containing valid EXIF data to:"
  echo "$(echo ${MOVETO})\$YYYY/\$MM/\$DD"
  echo ""
  exit
fi

###############################################
## nested execution call to perform the sort ##
###############################################
# invoked when the programs calls itself with
# $1 = "doAction"
# $2 = <file to handle>

# SKIP IF NOT CALLED BY SELF
if [[ "${1}" == "doAction" && "${2}" != "" ]]; then
  # fetch EXIF data
  DATETIME=`exif -t 'DateTime' -m ${2} 2>/dev/null | awk -F" " '{print $1}' | sed 's/\:/\//g' | sort -u`
  if [[ "${DATETIME}" == "" ]]; then
    echo "${2}: Abort! DateTime not found" | tee --append ${MOVETO}/$(date +%Y%m%d-%H%M)_import_failure.log
    exit 1;
  fi;
  if [[ "`echo ${DATETIME} | wc -l`" != "1" ]]; then
    echo "${2}: Abort! File has more than one DateTime declaration" | tee --append ${MOVETO}/$(date +%Y%m%d-%H%M)_import_failure.log
    exit 1;
  fi
  # lowercase filename and use the current extension as-is
  FILENAME=`echo ${2} | awk -F"/" '{print $NF}' | tr '[:upper:]' '[:lower:]'`
  # copy is safer than move
  mkdir -p "${MOVETO}/${DATETIME}" && cp -np "${2}" "${MOVETO}/${DATETIME}/${FILENAME}"
  echo ": success!"
  exit
fi;

##############################################
###### loop to find pictures and videos ######
##############################################
for x in ${FILETYPES}; do
  # check for exif command
  EXIF=`which exif`
  if [ "${EXIF}" == "" ]; then
    echo "Abort! The 'exif' command is missing or unavailable"
    exit 1
  fi;
  # locate and process found images
  find . -iname "*.${x}" -print0 -exec sh -c "$0 doAction '{}'" \;
done

# clean up empty dirs and dbs
find ${MOVETO} -name "Thumbs.db" -delete
find ${MOVETO} -empty -delete
