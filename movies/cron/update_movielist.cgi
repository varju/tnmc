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
use tnmc::mybc;

{
    #############
    ### Main logic

    &db_connect();
    
    print "Content-type: text/html\n\n<pre>\n";
    
    print "***********************************************************\n";
    print "****                 Get The Movie List                ****\n";
    print "***********************************************************\n";
    print "\n\n";
    
    my %list = mybc_get_movie_list();
    
    my $i = keys %list;
    print "$i movies found online at mybc.com\n\n";
    
    ### list of valid theatres
    my %valid_theatres = mybc_get_valid_theatres();
        
    print "***********************************************************\n";
    print "****               Retrieve the Movie Info             ****\n";
    print "***********************************************************\n";
    
    my @mShowing = ();
    
    my %mTitle;
    my %mStars;
    my %mPremise;
    my %mOurTheatres;
    
    foreach my $mID (sort(keys(%list))){
        my %movieInfo = mybc_get_movie_info($mID);
        if (!defined %movieInfo) {
            print "\n$mID (failed - parse error)";
            next;
        }

        $mTitle{$mID} = $movieInfo{title};
        $mStars{$mID} = $movieInfo{stars};
        $mPremise{$mID} = $movieInfo{premise};
        
        print "\n$mID    $mStars{$mID}    $mTitle{$mID}";
        
        # Pick out the theatres that we like
        my %mTheatres = %{$movieInfo{theatres}};
        
        foreach $_ (sort(keys(%mTheatres))){
            if ($valid_theatres{$_}){
                push (@mShowing, $mID);
                $mOurTheatres{$mID} = $mOurTheatres{$mID} . ' ' . $_;
                print " $_";
            }
        }
    }

    print "\n\n";
    print "***********************************************************\n";
    print "****               Update the Database                 ****\n";
    print "***********************************************************\n";

    my $sql = "UPDATE Movies SET statusShowing = '0', theatres = ''";
    my $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();
    $sth->finish();

    foreach my $mID (@mShowing){
      if ($mID){
        printf ("(%s)    %-40.40s", $mID, $mTitle{$mID});
    
        ####################
        ### Try to find movie in DB via mybcID

        $sql = "SELECT movieID FROM Movies WHERE mybcID = '$mID'";
        $sth = $dbh_tnmc->prepare($sql);
        $sth->execute();
        my @row = $sth->fetchrow_array();
        $sth->finish();
        my $movieID = $row[0];
        
        if ($movieID){
            print "   ..Found (mybcID)\n";
        }
        else {
        
            ####################
            ### Try to find movie in DB via Title
    
            $sql = "SELECT movieID FROM Movies
                 WHERE title = " . $dbh_tnmc->quote($mTitle{$mID});
            $sth = $dbh_tnmc->prepare($sql);
            $sth->execute();
            @row = $sth->fetchrow_array();
            $sth->finish();

            $movieID = $row[0];
            
            if ($movieID){
                print "   ..Found (Title)\n";
            }
        }

        if ($movieID){
            
                        my %dbMovie;
            &get_movie($movieID, \%dbMovie);

            $dbMovie{mybcID} = $mID;
            $dbMovie{statusShowing} = '1';
            $dbMovie{theatres} = $mOurTheatres{$mID};
            $dbMovie{rating} = $mStars{$mID};

            if (20 > length($dbMovie{description})){
                $dbMovie{description} = $mPremise{$mID};
            }
            
            &set_movie(%dbMovie);

            next;
        }
        
        ####################
        ### Can't find movie in DB. Let's make a new one.

        my %newMovie;
        $newMovie{movieID} = '0';
        $newMovie{mybcID} = $mID;
        $newMovie{title} = $mTitle{$mID};
        $newMovie{rating} = $mStars{$mID};
        $newMovie{description} = $mPremise{$mID};
        $newMovie{theatres} = $mOurTheatres{$mID};
        $newMovie{statusShowing} = '1';
        $newMovie{statusNew} = '1';
        $newMovie{statusSeen} = '0';
        $newMovie{statusBanned} = '0';
        $newMovie{date} = '0000-00-00';
        $newMovie{type} = '';
        
        &set_movie(%newMovie);
        
        print "   ..New Movie\n";
        
        
      }
    }

    &db_disconnect();
}
