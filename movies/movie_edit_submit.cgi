#!/usr/bin/perl

##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/';
use tnmc;
require 'MOVIES.pl';

	#############
	### Main logic
	
	$cgih = new CGI;
	
	&db_connect();

	@cols = &db_get_cols_list($dbh_tnmc, 'Movies');
 	foreach $key (@cols)
	{
	 	$movie{$key} = $cgih->param($key);
	}
	&set_movie(%movie);
	
	&db_disconnect();

	print "Location: index.cgi\n\n";

