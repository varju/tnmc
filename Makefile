auto/tnmc/movies/show/autosplit.ix: tnmc/movies/show.pm
	./autosplit.pl

TAGS:
	etags --append --language=perl *.p? */*.p? */*/*.p?
