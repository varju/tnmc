#!/usr/bin/perl

##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/usr/local/apache/tnmc';

use tnmc::config;
use tnmc::db;
use tnmc::general_config;
use tnmc::movies::movie;

	#############
	### Main logic

	&db_connect();

	my $winner_blurb = &get_general_config("movie_winner_blurb");
	my $current_movie =  &get_general_config("movie_current_movie");
        my $current_cinema = &get_general_config("movie_current_cinema");
        my $current_showtime = &get_general_config("movie_current_showtime");
        my $current_meeting_place = &get_general_config("movie_current_meeting_place");
        my $current_meeting_time = &get_general_config("movie_current_meeting_time");
        
        my $sql = "SELECT DATE_ADD(NOW(), INTERVAL ((9 - DATE_FORMAT(NOW(), 'w') ) % 7) DAY)";
        my $sth = $dbh_tnmc->prepare($sql);
        $sth->execute();
        my ($next_tuesday) = $sth->fetchrow_array();
        $sth->finish();
        
        $sql = "SELECT DATE_FORMAT('$next_tuesday', 'W M D, Y')";
        $sth = $dbh_tnmc->prepare($sql);
        $sth->execute();
        my ($next_tuesday_string) = $sth->fetchrow_array();
        $sth->finish();
  

	# If there is no current movie, don't do anything.
	if (!$current_movie) 
	{
		exit;
	}


        my %movie;
	&get_movie($current_movie, \%movie);
	my $current_movie_name = $movie{'title'};

        
        my $to_email = $tnmc_email;

        open(SENDMAIL, "| /usr/sbin/sendmail $to_email");
        print SENDMAIL "From: TNMC Website <scottt\@interchange.ubc.ca>\n";
        print SENDMAIL "To: tnnc-list <$to_email>\n";
        print SENDMAIL "Subject: $next_tuesday_string\n";
        print SENDMAIL "\n";
        
	print SENDMAIL "\n";
	print SENDMAIL "$winner_blurb\n";
	print SENDMAIL "\n";
	print SENDMAIL "Movie:           $current_movie_name\n";
	print SENDMAIL "Cinema:          $current_cinema\n";
	print SENDMAIL "Showtime:        $current_showtime\n";
	print SENDMAIL "Meeting Time:    $current_meeting_time\n";
	print SENDMAIL "Meeting Place:   $current_meeting_place\n";

        close SENDMAIL;


	&db_disconnect();


##########################################################
#### The end.
##########################################################

