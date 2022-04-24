autosplit:
	./autosplit.pl

TAGS:
	etags --append --language=perl `find . -name '*.p?'`

tidy:
	git ls-files "*.pl" "*.pm" "*.cgi" | grep -v admin/errorlog.cgi | xargs perltidy \
	  --backup-and-modify-in-place \
	  --backup-file-extension=/ \
	  --maximum-line-length=120 \
	  --want-break-after="||" \
	  --paren-tightness=2
