#!/usr/bin/perl

##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

use lib '/usr/local/apache/tnmc/';
use tnmc;


	#############
	### Main logic

	&db_connect();
	&header();

	%user;	
	$cgih = new CGI;


 	&show_heading ("dev job list");
	$devBlurb =  &get_general_config("devBlurb");
	$devBlurb =~ s/\n/<br>/gs;
	print $devBlurb;

 	&show_heading ("suggestion box");
	$suggBlurb =  &get_general_config("suggestions");
	$suggBlurb =~ s/\n/<br>/gs;
	print $suggBlurb;


	&footer();

