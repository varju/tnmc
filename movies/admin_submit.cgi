#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
#	Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc';
use tnmc;
require 'MOVIES.pl';

	#############
	### Main logic
	
	$cgih = new CGI;
	
	&db_connect();

	@params =  $cgih->param();
        
	foreach $_ (@params)
	{	$val = $cgih->param($_);
		&set_general_config($_, $val);
        }

	&db_disconnect();

	print "Location: index.cgi\n\n";

