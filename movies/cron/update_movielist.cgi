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

        #############
        ### Main logic

        print "Content-type: text/html\n\n<pre>\n";

    print "***********************************************************\n";
    print "****                 Get The Movie List                ****\n";
    print "***********************************************************\n";
    print "\n";

    ######################
    print "Searching through Directory Listing\n";

    my $URL = "http://www2.mybc.com/aroundtown/movies/playing/movies/";

        ### Get a User agent
        my $ua = new LWP::UserAgent;
        $ua->agent("tnmcWebAgent/01 " . $ua->agent);

        ### Make the Request
        my $req = new HTTP::Request GET => $URL;
        my $res = $ua->request($req);

    my $directory = $res->content;
    my @directory = split("\n", $directory);

        my %list;
    foreach my $line (@directory){
        #print "    $line\n";
        if ($line =~ /^<A HREF=\"(\d+).html\"/i) {
    #        print "$1\n";
            $list{$1} = '';
        }
    }
    ######################
    print "Searching through Drop-down menu\n";
    
        ### Make the Request
    $URL = "http://www2.mybc.com/aroundtown/movies/";
        $req = new HTTP::Request GET => $URL;
        $res = $ua->request($req);

    my $list = $res->content;
    $list =~ s/.*\n\<SELECT name\=\"movieid\"\>\n//s;
    $list =~ s/\n\<\/SELECT\>\n.*//s;

    my @list = split("\n", $list);

    foreach my $item (@list){
        $item =~ /.+\"(\d+)\"\>(.*)$/;
        $list{$1} = $2;
    }

    #    foreach $mybcID (sort(keys(%list))){
    #        print "$mybcID    $list{$mybcID}\n";
    #    }

    my $i = 0;
    foreach (keys(%list)){
        $i++;
    }    
    print "\n" . $i . " movies found online at mybc.com\n\n";
    

    ### list of valid theatres
    print "Ordered List of Acceptable Theatres:\n";
    print "------------------------------------\n";
    &db_connect();
    my $valid_theatres = &get_general_config("movie_valid_theatres");
    my @valid_theatres = split(/\s/, $valid_theatres);
        my %valid_theatres;
    foreach (@valid_theatres){
        $valid_theatres{$_} = 1;
        print $_ . "\n";
    }
    
    print "\n";


    print "***********************************************************\n";
    print "****               Retrieve the Movie Info             ****\n";
    print "***********************************************************\n";

    my @mShowing = ();

        my %mTitle;
        my %mStars;
        my %mPremise;
        my %mOurTheatres;

    foreach my $mID (sort(keys(%list))){
                my $mTheatres;
                my $mInfo;
        
        #################
        ### Request the page

        $URL = "http://www2.mybc.com/aroundtown/movies/playing/movies/$mID.html";
        my $req = new HTTP::Request GET => $URL;
        $res = $ua->request($req);

        my $mPage = $res->content;
        
        #################
        ### Parse the page

        if ($mPage =~ s/.*\n<TD WIDTH="456" VALIGN="top">\n//s){

            $mPage =~ /<FONT SIZE="4">((.)*)<\/FONT>/m;
            $mTitle{$mID} = $1;
            $mTitle{$mID} =~ s/^(The|A)\s+(.*)$/$2, $1/;

            $mStars{$mID} = 0;
            if ($mPage =~ /<IMG SRC="\/aroundtown\/movies\/images\/star_(.*)\.gif/m){
                $mStars{$mID} = $1;
                $mStars{$mID} =~ s/_half/.5/;
            }
            
            $mPage =~ s/.*\n<B><I>\@ THESE LOCATIONS<\/I><\/B>\:\n<BR>\n//s;
            $mPage =~ s/^(.*)\n//;
            $mTheatres = $1;

            $mPage =~ s/^<P>(.*)<P>\n//s;
            $mInfo = $1;
            
            if ($mInfo =~ s/\n<B>PREMISE<\/B>\:<BR>\n//m){
                ($mPremise{$mID}, $mInfo) = split("\n", $mInfo, 2);
            }
        }
        else{
            ### Could not parse
            print "\n$mID (failed)";
            next;
        }

        print "\n$mID    $mStars{$mID}    $mTitle{$mID}";

        #################
        ### Extract the Theatres

        my @mTheatres = split('<BR>&#160;&#160;', $mTheatres);
        my %mTheatres = ();
        foreach my $mTh (@mTheatres){
            if (!$mTh) {    next;    }
            $mTh =~ /cinemas\/(.+)\.html">(.+)<\/A>$/;
            $mTheatres{$1} = $2;
            print ".";
        }

        #################
        ### Pick out the theatres that we like

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



        &db_connect();

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

#            if (! $dbMovie{rating}){
                $dbMovie{rating} = $mStars{$mID};
#            }

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

    $sth->finish();

        &db_disconnect();


