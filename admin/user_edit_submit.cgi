#!/usr/bin/perl

##################################################################
#	Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

use lib '/usr/local/apache/tnmc';
use tnmc;

require 'basic_testing_tools.pl';

	#############
	### Main logic
	
	$cgih = new CGI;
	
	&db_connect();

	@cols = &db_get_cols_list($dbh_tnmc, 'Personal');
 	foreach $key (@cols)
	{ 	$user{$key} = $cgih->param($key);
	}
	&set_user(%user);
	
	&db_disconnect();

	print "Location: index.cgi\n\n";

