#!/usr/bin/perl

##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/usr/local/apache/tnmc';

use tnmc::db;
use tnmc::general_config;
use tnmc::broadcast;
use tnmc::user;
use tnmc::movies::movie;

	#############
	### Main logic

	&db_connect();

        my (@users, $userID, %user, %movie);

	my $current_movie =  &get_general_config("movie_current_movie");
        my $current_cinema = &get_general_config("movie_current_cinema");
        my $current_showtime = &get_general_config("movie_current_showtime");
        my $current_meeting_place = &get_general_config("movie_current_meeting_place");
        my $current_meeting_time = &get_general_config("movie_current_meeting_time");

	### If there is no current movie, don't do anything.
	if (!$current_movie) 
	{	exit;
	}

	### Put the message together
	&get_movie($current_movie, \%movie);
	my $current_movie_name = $movie{'title'};

	my $message = " $current_movie_name ---------------- Meet at $current_meeting_place \@ $current_meeting_time\. ---------------- $current_cinema \@ $current_showtime\.";

	### User List of people who want movie notification
        &list_users(\@users, "WHERE movieNotify = '1'", 'ORDER BY username');

	### Broadcast the message
	&smsBroadcast(\@users, $message);

	&db_disconnect();



##########################################################
#### The end.
##########################################################

