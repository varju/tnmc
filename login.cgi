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

	my (%user, %old_user, $userID, $password);

	$userID = $cgih->param('userID');
	$password = $cgih->param('password');
	&get_user($userID, \%user);

        %tnmc_cookie_in = $cgih->cookie('TNMC');
        $old_user = $tnmc_cookie_in{'userID'};
	&get_user($old_user, \%old_user);


	############################
	### Do the date stuff.
	open (DATE, "/bin/date |");
	while (<DATE>) {
	    chop;
	    $today = $_;
	}
	close (DATE);

	open (LOG, '>>log/login.log');
	print LOG "$today\t$ENV{REMOTE_ADDR}\t$ENV{REMOTE_HOST}";
	print LOG "\t$old_user\t$old_user{username}\t->\t$userID";
	print LOG "\t$user{username}\tpass: $password";
	
	%cookie_out = (
		'userID' => $userID,
		'logged-in' => '1'
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
	if (	($password ne $user{'password'}) && ($user{'password'} ne '')	){
		&header();
		print qq{
			<p>
			<b>
			Oopsie-daisy!</b>
			<p>
			You entered the wrong password.
		};
		&footer();
		print LOG "\tFAILED";
	}
	elsif ($userID){
		print $cgih->redirect(
			-uri=>$location,
			-cookie=>$tnmc_cookie
			);
	}
	else{
		print $cgih->redirect(-uri=>$location);
	}

	print LOG "\n";
	close (LOG);

	&db_disconnect();

##########################################################
#### The end.
##########################################################

