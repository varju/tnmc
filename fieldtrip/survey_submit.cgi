#!/usr/bin/perl

##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc';
use tnmc;
require 'fieldtrip/FIELDTRIP.pl';

	#############
	### Main logic
	
	$cgih = new CGI;
	
	&db_connect();

	@cols = &db_get_cols_list($dbh_tnmc, 'FieldtripSurvey');
 	foreach $key (@cols){
	 	$survey{$key} = $cgih->param($key);
	}

	&set_tripSurvey(%survey);

	&db_disconnect();

	print "Location: index.cgi\n\n";

