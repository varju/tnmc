#!/usr/bin/perl

##################################################################
#	Scott Thompson
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
	
	&db_connect();

        my $picID = $cgih->param(picID);
        my $albumID = $cgih->param(albumID);

        if ($picID && $albumID){
            &add_link($picID, $albumID);
	};
	&db_disconnect();

 	$destination = $cgih->param(destination) || $ENV{HTTP_REFERER};

	print "Location: $destination\n\n";
}

