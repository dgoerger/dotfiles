make:
	/bin/ksh make_mandoc_html.sh
	find outdir -type f -name "*.html" -exec chmod 0444 {} \+
clean:
	find outdir -type f -name "*.html" -delete
	/bin/rm -f outdir/mandoc.css mandoc.css
	rmdir outdir
