#!/usr/bin/perl

##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/';
use tnmc;
require 'movies/MOVIES.pl';

	#############
	### Main logic

	&db_connect();

        my (@users, $userID, %user, %movie);

	$current_movie =  &get_general_config("movie_current_movie");
        $current_cinema = &get_general_config("movie_current_cinema");
        $current_showtime = &get_general_config("movie_current_showtime");
        $current_meeting_place = &get_general_config("movie_current_meeting_place");
        $current_meeting_time = &get_general_config("movie_current_meeting_time");

	### If there is no current movie, don't do anything.
	if (!$current_movie) 
	{	exit;
	}

	### Put the message together
	&get_movie($current_movie, \%movie);
	$current_movie_name = $movie{'title'};

	$message = "TNMC: $current_movie_name ---------------- Meet at $current_meeting_place \@ $current_meeting_time\. ---------------- $current_cinema \@ $current_showtime\.";

	### User List of people who want movie notification
        &list_users(\@users, "WHERE movieNotify = '1'", 'ORDER BY username');

	### Broadcast the message
	&smsBroadcast(\@users, $message);

	&db_disconnect();



##########################################################
#### The end.
##########################################################

