#!/usr/bin/perl

##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/';
use tnmc;
use tnmc::movies::night;


	#############
	### Main logic
	
	$cgih = new CGI;
	
	&db_connect();

	@cols = &db_get_cols_list($dbh_tnmc, 'MovieNights');
 	foreach $key (@cols){
	 	$night{$key} = $cgih->param($key);
	}

	&set_night(%night);
	
	&db_disconnect();

	print "Location: index.cgi\n\n";

