#!/usr/bin/perl

##################################################################
#	Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

use lib '/usr/local/apache/tnmc/';
use tnmc;

require 'basic_testing_tools.pl';

	#############
	### Main logic
	
	$cgih = new CGI;
	&db_connect();
	# &header();

	my $group = $cgih->param(group);

	#
	# fore every user that's been submited,
	# see if the rank for this group has changed,
	# if so, then save the new rank in the db.
	#
	foreach $key ($cgih->param()){
		
		next if ($key !~ s/^USER//);
		$newRank = $cgih->param("USER$key");

		&get_user($key, \%user);
		if ($newRank ne $user{"group$group"}){
			$user{"group$group"} = $newRank;
			&set_user(%user);
			## debugging
			# print "$key : " . $cgih->param("USER$key") ." $user{username} <br>";
		}
	}

	# &footer();
	&db_disconnect();

	print "Location: groups.cgi?groupID=$group\n\n";

