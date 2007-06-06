autosplit:
	./autosplit.pl

TAGS:
	etags --append --language=perl `find . -name '*.p?'`
