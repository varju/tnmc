#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.


use lib '/tnmc';

use tnmc::cookie;
use tnmc::db;
use tnmc::template;

require 'pics/PICS.pl';

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
