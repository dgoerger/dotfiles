VERSION := 7.7

make:
	/bin/ksh make_mandoc_html.sh
	find outdir -type f -name "*.html" -exec chmod 0444 {} \+
	doas rsync -a outdir /var/www/files/pub/OpenBSD/$(VERSION)/manuals

zim:
	podman run -ti --rm -v $(PWD):/output ghcr.io/openzim/zimit zimit --seeds "https://files.daemonica.net/pub/OpenBSD/$(VERSION)/manuals/" --name openbsd$(VERSION).zim --workers 4 --keep --title "OpenBSD $(VERSION)" --description "System programmer manuals for OpenBSD $(VERSION)." --lang "en" --zim-lang "eng"

clean:
	find outdir -type f -name "*.html" -delete
	/bin/rm -f outdir/mandoc.css mandoc.css
	rmdir outdir
