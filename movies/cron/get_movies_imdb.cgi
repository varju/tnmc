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
use tnmc::movies::movie;
use tnmc::imdb;

{
    #############
    ### Main logic

    my $dbh = &tnmc::db::db_connect();
    
    print "Content-type: text/html\n\n<pre>\n";
    
    print "***********************************************************\n";
    print "****                 Get The Movie List                ****\n";
    print "***********************************************************\n";
    print "\n\n";
    
    my %list = &tnmc::imdb::imdb_get_movie_list();
    
    my $i = keys %list;
    print "$i movies found online at imdb.com\n\n";
    
    print "***********************************************************\n";
    print "****               Retrieve the Movie Info             ****\n";
    print "***********************************************************\n";
    
    my %mTitle;
    my %mStars;
    my %mPremise;
    
    foreach my $mID (sort(keys(%list))){
        my %movieInfo = &tnmc::imdb::imdb_get_movie_info($mID);
	
        if (!defined %movieInfo) {
            print "\n$mID (failed - parse error)";
            next;
        }
	
#	push @MOVIES, \%movieInfo;
	
        $mTitle{$mID} = $list{$mID};
#        $mStars{$mID} = $movieInfo{stars};
        $mPremise{$mID} = $movieInfo{premise};
        
        print "\n$mID    $mStars{$mID}    $mTitle{$mID}";
        
    }
    
    print "\n\n";
    print "***********************************************************\n";
    print "****               Update the Database                 ****\n";
    print "***********************************************************\n";

    foreach my $mID (keys %list) {
      if ($mID){
        printf ("(%s)    %-40.40s", $mID, $list{$mID});
    
        ####################
        ### Try to find movie in DB via mybcID

        my $sql = "SELECT movieID FROM Movies WHERE imdbID = '$mID'";
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        my @row = $sth->fetchrow_array();
        $sth->finish();
        my $movieID = $row[0];
        
        if ($movieID){
            print "   ..Found (imdbID)\n";
        }
        else {
	    
            ####################
            ### Try to find movie in DB via Title
    
            $sql = "SELECT movieID FROM Movies
                 WHERE title = " . $dbh->quote($mTitle{$mID});
            $sth = $dbh->prepare($sql);
            $sth->execute();
            @row = $sth->fetchrow_array();
            $sth->finish();

            $movieID = $row[0];
            
            if ($movieID){
                print "   ..Found (Title)\n";
            }
        }
	
	## save changes to DB
        if ($movieID){
            
            my %dbMovie;
            &tnmc::movies::movie::get_movie($movieID, \%dbMovie);

            $dbMovie{imdbID} = $mID;
	    
            if (20 > length($dbMovie{description})){
                $dbMovie{description} = $mPremise{$mID};
            }
            #print %dbMovie;
            &tnmc::movies::movie::set_movie(%dbMovie);

            next;
        }
#        
#        ####################
#        ### Can't find movie in DB. Let's make a new one.
#
#        my %newMovie;
#        $newMovie{movieID} = '0';
#        $newMovie{imdbID} = $mID;
#        $newMovie{title} = $mTitle{$mID};
#        # $newMovie{rating} = $mStars{$mID};
#        $newMovie{description} = $mPremise{$mID};
#        # $newMovie{theatres} = $mOurTheatres{$mID};
#        $newMovie{statusShowing} = '0';
#        $newMovie{statusNew} = '1';
#        $newMovie{statusSeen} = '0';
#        $newMovie{statusBanned} = '0';
#        $newMovie{date} = '0000-00-00';
#        $newMovie{type} = '';
#        
#        &tnmc::movies::movie::set_movie(%newMovie);
#        
#        print "   ..New Movie\n";
        
        
      }
    }

    &tnmc::db::db_disconnect();
}


