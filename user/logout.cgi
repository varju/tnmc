#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca         
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

use lib '/usr/local/apache/tnmc/';
use tnmc;

	#############
	### Main logic

	&db_connect();

	$cgih = new CGI;

        %tnmc_cookie_in = $cgih->cookie('TNMC');
	$userID = $tnmc_cookie_in{'userID'};

	%cookie_out = (
		'userID' => $userID,
		'logged-in' => '0'
		);

	$tnmc_cookie = $cgih->cookie(
		-name=>'TNMC',
		-value=>\%cookie_out,
		-expires=>'+1y',
		-path=>'/',
		-domain=>'tnmc.dhs.org',
		-secure=>'0'
		);

	$location = 'http://tnmc.dhs.org/index.cgi';
	print $cgih->redirect(
		-uri=>$location,
		-cookie=>$tnmc_cookie);

	&db_disconnect();

##########################################################
#### The end.
##########################################################

