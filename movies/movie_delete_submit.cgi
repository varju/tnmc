#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
#       Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/';
use tnmc;
require 'MOVIES.pl';


	#############
	### Main logic

	$cgih = new CGI;
	$movieID = $cgih->param('movieID');	
	
	if ($movieID)
	{ 	&db_connect();
		&del_movie($movieID);
		&db_disconnect();
	}

	print "Location: index.cgi\n\n";

