#!/usr/bin/perl

##################################################################
# Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;

require 'pics/PICS.pl';

{
	#############
	### Main logic

	$cgih = new CGI;
	$picID = $cgih->param('picID');	
	
	if ($picID)
	{ 	&db_connect();
		&del_pic($picID);
		&db_disconnect();
	}

	print "Location: index.cgi\n\n";
}
