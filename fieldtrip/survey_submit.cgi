#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::user;
use tnmc::cgi;

require 'fieldtrip/FIELDTRIP.pl';

    #############
    ### Main logic
    
    &db_connect();
    
    $tripID = &tnmc::cgi::param('tripID');
    $userID = &tnmc::cgi::param('userID');
    
    my %survey;
    &get_tripSurvey($tripID, $userID, \%survey);
    
    
    
    @cols = &db_get_cols_list('FieldtripSurvey');
    foreach $key (@cols){
         $survey{$key} = &tnmc::cgi::param($key) if (defined &tnmc::cgi::param($key));
    }

    &set_tripSurvey(%survey);

    &db_disconnect();

    print "Location: index.cgi\n\n";

