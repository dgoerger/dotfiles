#!/bin/ksh -
set -Cefuo pipefail

mkdir -m 755 outdir
if [[ -r /usr/share/misc/mandoc.css ]]; then
        install -pm 444 /usr/share/misc/mandoc.css mandoc.css
        ln mandoc.css outdir/mandoc.css
fi

for i in $(jot 9); do
        SECTION="/usr/share/man/man${i}"
        /bin/ls "${SECTION}" | while read -r FILE; do
                if [[ -f "${SECTION}/${FILE}" ]]; then
                        mandoc -T html -O style=mandoc.css "${SECTION}/${FILE}" > "outdir/${FILE%.gz}.html"
                fi
        done
done
