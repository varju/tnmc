#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.


use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::pics::album;


{
	#############
	### Main logic
	
	$cgih = new CGI;
	
	&db_connect();

	@cols = &db_get_cols_list('PicAlbums');
 	foreach $key (@cols)
	{ 	$album{$key} = $cgih->param($key);
	}
	&set_album(%album);
	
	&db_disconnect();

	print "Location: $ENV{HTTP_REFERER}\n\n";
}
