#!/usr/bin/perl

##################################################################
#     Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use CGI;

use lib '/tnmc';

use tnmc::db;
use tnmc::movies::attend;

    #############
    ### Main logic

    &db_connect();

                my $cgih = new CGI;

        my %attendance = {};
        # get each field
            my @params =  $cgih->param();
        foreach $_ (@params){
            if (! /^movie/) { next; }
            $attendance{$_} = $cgih->param($_);
        }

        # get the userid 
        $attendance{userID} = $cgih->param('userID');

        # send it to the db.
        &set_attendance(%attendance);

        print "Location: $ENV{HTTP_REFERER}\n\n";
        
    &db_disconnect();

##########################################################
#### The end.
##########################################################
