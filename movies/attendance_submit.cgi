#!/usr/bin/perl

##################################################################
# 	Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc';
use tnmc;
require 'MOVIES.pl';

	#############
	### Main logic

	&db_connect();

      	  	$cgih = new CGI;

		%attendance = {};
		# get each field
        	@params =  $cgih->param();
		foreach $_ (@params){
			if (! /^movie/) { next; }
			$attendance{$_} = $cgih->param($_);
		}

		# get the userid 
		$attendance{userID} = $cgih->param('userID');

		# send it to the db.
		&set_attendance(%attendance);

		print "Location: $ENV{HTTP_REFERER}\n\n";
		
	&db_disconnect();

##########################################################
#### The end.
##########################################################

