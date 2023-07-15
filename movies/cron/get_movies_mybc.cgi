#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@css.sfu.ca (dec/99)
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use LWP::UserAgent;
use HTTP::Request::Common qw(POST);

use strict;
use warnings;

use lib '/tnmc';

use tnmc::db;
use tnmc::general_config;
use tnmc::movies::movie;
use tnmc::updater::mybc;

{
    #############
    ### Main logic

    my $dbh = &tnmc::db::db_connect();

    print "Content-Type: text/html; charset=utf-8\n\n<pre>\n";

    print "***********************************************************\n";
    print "****           MYBC: Get The Movie List                ****\n";
    print "***********************************************************\n";
    print "\n\n";

    my %list = &tnmc::updater::mybc::mybc_get_movie_list();

    my $i = keys %list;
    print "$i movies found online at mybc.com\n\n";

    print "***********************************************************\n";
    print "****        MYBC:  Retrieve the Movie Info             ****\n";
    print "***********************************************************\n";

    my %mShowing = ();

    my %mTitle;
    my %mStars;
    my %mPremise;
    my %mOurTheatres;

    my @MOVIES;

    foreach my $mID (sort(keys(%list))) {
        my %movieInfo = &tnmc::updater::mybc::mybc_get_movie_info($mID);
        if (!%movieInfo) {
            print "\n$mID (failed - parse error)";
            next;
        }

        push @MOVIES, \%movieInfo;
        print "\n$mID     $movieInfo{title}";
    }

    print "\n\n";
    print "***********************************************************\n";
    print "****               Update the Database                 ****\n";
    print "***********************************************************\n";

    foreach my $movieInfo (@MOVIES) {
        my $mID = $movieInfo->{mybcID};

        printf("(%s)    %-40.40s", $mID, $movieInfo->{title});

        my $movie;
        my $movieID;

        ## find: mybcID
        $movie = &tnmc::movies::movie::get_movie_by_mybcid($mID);
        if ($movie->{movieID}) {
            $movieID = $movie->{movieID};
            print "(mybcid $movieID)";
        }

        ## find: title
        if (!$movieID) {
            $movieID = &tnmc::movies::movie::get_movieid_by_title($movieInfo->{title});
            if ($movieID) {
                $movie = &tnmc::movies::movie::get_movie($movieID);
                $movie->{mybcID} = $mID;
                &tnmc::movies::movie::set_movie($movie);
                print "(title $movieID)";
            }
        }

        ## not found
        if (!$movieID) {
            print "(not found in db)";
        }

        ## update movie info
        if ($movieID) {

            $movie->{rating} = $movieInfo->{stars};

            if (20 > length($movie->{description})) {
                $movie->{description} = $movieInfo->{premise};
            }
            &tnmc::movies::movie::set_movie($movie);
        }

        print "\n";
    }
}

