#!/usr/bin/perl

##################################################################
# 	Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/';
use tnmc;
require 'MOVIES.pl';

	#############
	### Main logic

	&db_connect();


      	  	$cgih = new CGI;
		$userID = $cgih->param('userID');
        	@params =  $cgih->param();

		%vote_count = {};
		$favoriteMovie = $cgih->param('favoriteMovie');


		### cont the number of positive/negative/neutral votes.
		foreach $_ (@params){
			if (! /^v/) { next; }
			$type = $cgih->param($_);
			$vote_count{$type} += 1;
		}

		### grumpy people who make too many negative votes get denied.
		if ($vote_count{'1'} < $vote_count{'-1'}){
			&header();
			print qq{
				<p><b>Hey silly...</b>
				<p>What's the point in having $vote_count{-1} anti-votes
				and only $vote_count{1} real votes?
				<p>Why don't ya go back and try to be a little more positive next time 'round.
			};
			&footer();
			exit(1);
		}

		### do the processing.
		foreach $_ (@params){
			if (! s/^v//) { next; }
			&set_vote($_, $userID, $cgih->param("v$_"));
		}

		if ($favoriteMovie ne ''){
			### Kill old Fave.
			$sql = "UPDATE MovieVotes SET type = '1' WHERE type = '2' AND userID = '$userID'";
			$sth = $dbh_tnmc->prepare($sql);
			$sth->execute;
			
			### Set new Fave.
			if ($favoriteMovie){ &set_vote($favoriteMovie, $userID, '2');}
		}

		print "Location: $ENV{HTTP_REFERER}\n\n";
		
	&db_disconnect();

##########################################################
#### The end.
##########################################################

