#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/';
use tnmc;
require 'pics/PICS.pl';

{
	#############
	### Main logic
	
	$cgih = new CGI;
	
	&db_connect();

	@cols = &db_get_cols_list($dbh_tnmc, 'PicAlbums');
 	foreach $key (@cols)
	{ 	$album{$key} = $cgih->param($key);
	}
	&set_album(%album);
	
	&db_disconnect();

	print "Location: $ENV{HTTP_REFERER}\n\n";
}
