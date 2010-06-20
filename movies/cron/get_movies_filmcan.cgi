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
use tnmc::movies::showtimes;
use tnmc::filmcan;
use tnmc::mybc;

{
    #############
    ### Main logic

    my $dbh = &tnmc::db::db_connect();
    
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
    foreach my $theatreID (keys %$showtimes){

	## set new showtimes
	my $listings = $showtimes->{$theatreID};
	my $theatre = &tnmc::movies::theatres::get_theatre($theatreID);
	print "$theatre->{name}\n";
	
	foreach my $listing (@$listings){
	    print "\t$listing->{filmcanid}\t$listing->{title} ";
	    
	    ## find movie
	    my $movie;
	    my $movieID;
	    
	    $movie = &tnmc::movies::movie::get_movie_by_filmcanid($listing->{filmcanid});
	    if ($movie->{movieID}){
		$movieID = $movie->{movieID};
		$movie->{statusShowing} = 1;
		&tnmc::movies::movie::set_movie($movie);
		print "(filmcanid $movieID)";
	    }
	    else{
		$movieID = &tnmc::movies::movie::get_movieid_by_title($listing->{title});
		if ($movieID){
		    $movie = &tnmc::movies::movie::get_movie($movieID);
		    $movie->{filmcanID} = $listing->{filmcanid};
		    $movie->{statusShowing} = 1;
		    
		    print "(title $movieID)";
		    &tnmc::movies::movie::set_movie($movie);
		}
	    }
	    
	    ## add new movie
	    if (!$movie->{movieID}){
		$movie = &tnmc::movies::movie::new_movie();
		$movie->{title} = $listing->{title};
		$movie->{filmcanID} = $listing->{filmcanid};
		$movie->{statusNew} = 1;
		$movie->{statusBanned} = 0;
		$movie->{statusSeen} = 0;
		$movie->{statusShowing} = 1;
		
		$movieID = &tnmc::movies::movie::add_movie($movie);
		$movie = &tnmc::movies::movie::get_movie($movieID);
		
		## LAZY: should verify add here.
		
		print "(new $movieID)";
	    }
	    
	    ## update showtimes
	    my $showtimes = &tnmc::movies::showtimes::new_showtimes;
	    $showtimes->{theatreID} = $theatreID;
	    $showtimes->{movieID} = $movie->{movieID};
	    &tnmc::movies::showtimes::set_showtimes($showtimes);

	    print "\n";
	    
	}
    }
    
    ### update the movie caches
    
    require tnmc::movies::night;
    &tnmc::movies::night::update_all_cache_movieIDs();
    
    &tnmc::db::db_disconnect();
}

sub get_theatres
{
    print "***********************************************************\n";
    print "****           FILMCAN: Get The Theatre List           ****\n";
    print "***********************************************************\n";
    print "\n\n";

    my @theatres = &tnmc::movies::theatres::list_theatres("WHERE filmcanid != ''");
    print join " ", @theatres;
    print "\n\n";

    retun \@theatres;
}

sub get_showtimes
{
    my ($theatres) = @_;

    print "***********************************************************\n";
    print "****           FILMCAN: Get The Showtimes              ****\n";
    print "***********************************************************\n";
    print "\n\n";
    
    my %SHOWTIMES;
    foreach my $theatreID (@$theatres){
	my $theatre = &tnmc::movies::theatres::get_theatre($theatreID);
	
	print "$theatre->{name}\n";
	
	my $showtimes = &tnmc::filmcan::get_theatre_showtimes($theatre->{filmcanid});
	
	# map {print "\t$_->{title}\n";} @$showtimes;
	
	$SHOWTIMES{$theatreID} = $showtimes;
	
    }

    return \%SHOWTIMES;
}
