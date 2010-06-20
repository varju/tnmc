#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@css.sfu.ca (dec/99)
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use LWP::UserAgent;
use HTTP::Request::Common qw(POST);

use strict;
use lib '/tnmc';

use tnmc::db;
use tnmc::general_config;
use tnmc::movies::cron;
use tnmc::movies::movie;
use tnmc::movies::night;
use tnmc::movies::showtimes;
use tnmc::cinemaclock;
use tnmc::mybc;

sub main
{
    $| = 1;
    print "Content-type: text/html\n\n<pre>\n";
    
    my $theatres = get_theatres();
    my $showtimes = get_showtimes($theatres);

    print "\n\n";
    print "***********************************************************\n";
    print "****               Update the Database                 ****\n";
    print "***********************************************************\n";
    print "\n\n";

    &tnmc::movies::cron::reset_status_showing();

    ## del old showtimes
    &tnmc::movies::showtimes::del_all_showtimes();

    ## update movies
    foreach my $theatreID (keys %$showtimes) {
	process_theatre($theatreID, $showtimes->{$theatreID});
    }

    ### update the movie caches
    &tnmc::movies::night::update_all_cache_movieIDs();

    &tnmc::db::db_disconnect();
}

sub get_theatres
{
    print "***********************************************************\n";
    print "****           CINEMACLOCK: Get The Theatre List           ****\n";
    print "***********************************************************\n";
    print "\n\n";
    
    my @theatres = &tnmc::movies::theatres::list_theatres("WHERE cinemaclockid != ''");
    print join " ", @theatres;
    print "\n\n";

    return \@theatres;
}

sub get_showtimes
{
    my ($theatres) = @_;

    print "***********************************************************\n";
    print "****           CINEMACLOCK: Get The Showtimes              ****\n";
    print "***********************************************************\n";
    print "\n\n";
    
    my %SHOWTIMES;
    foreach my $theatreID (@$theatres){
	my $theatre = &tnmc::movies::theatres::get_theatre($theatreID);
	print "Theatre: $theatre->{name}\n";
	
	my $showtimes = &tnmc::cinemaclock::get_theatre_showtimes($theatre->{cinemaclockid});
	foreach my $listing (@$showtimes) {
	    print $listing->{cinemaclockid}, "   ", $listing->{title}, "    ", $listing->{page}, "\n";
	}

	$SHOWTIMES{$theatreID} = $showtimes;
	
    }

    return \%SHOWTIMES;
}

## sets new showtimes
sub process_theatre
{
    my ($theatreID, $listings) = @_;

    my $theatre = &tnmc::movies::theatres::get_theatre($theatreID);
    print "$theatre->{name}\n";

    foreach my $listing (@$listings) {
	print "\t$listing->{cinemaclockid}\t$listing->{title} ";

	## find movie
	my $movie = get_or_create_movie($listing->{cinemaclockid}, $listing->{title});

	## update attributes
	$movie->{cinemaclockID} = $listing->{cinemaclockid};
	$movie->{cinemaclockPage} = $listing->{page};
	$movie->{statusShowing} = 1;
	$movie->{title} = $listing->{title};
	&tnmc::movies::movie::set_movie($movie);

	## update showtimes
	add_showtime($theatreID, $movie->{movieID});
	
	print "\n";
    }
}

sub get_or_create_movie
{
    my ($cinemaclockid, $title) = @_;

    my $movie = &tnmc::movies::movie::get_movie_by_cinemaclockid($cinemaclockid);
    if ($movie->{movieID}) {
	print "(cinemaclockid ", $movie->{movieID}, ")";
	return $movie;
    }

    my $movieID = &tnmc::movies::movie::get_movieid_by_title($title);
    if ($movieID) {
	print "(title $movieID)";
	return &tnmc::movies::movie::get_movie($movieID);
    }

    ## add new movie
    $movie = &tnmc::movies::movie::new_movie();
    $movie->{title} = $title;
    $movie->{cinemaclockID} = $cinemaclockid;

    $movie->{statusBanned} = 0;
    $movie->{statusNew} = 1;
    $movie->{statusSeen} = 0;

    $movieID = &tnmc::movies::movie::add_movie($movie);
    print "(new $movieID)";
    return &tnmc::movies::movie::get_movie($movieID);
}

sub add_showtime
{
    my ($theatreID, $movieID) = @_;

    my $showtimes = &tnmc::movies::showtimes::new_showtimes();
    $showtimes->{theatreID} = $theatreID;
    $showtimes->{movieID} = $movieID;
    &tnmc::movies::showtimes::set_showtimes($showtimes);
}

main();
