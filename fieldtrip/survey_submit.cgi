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

require 'fieldtrip/FIELDTRIP.pl';

    #############
    ### Main logic
    
    $cgih = new CGI;
    
    &db_connect();
    
    $tripID = $cgih->param('tripID');
    $userID = $cgih->param('userID');
    
    my %survey;
    &get_tripSurvey($tripID, $userID, \%survey);
    
    
    
    @cols = &db_get_cols_list('FieldtripSurvey');
    foreach $key (@cols){
         $survey{$key} = $cgih->param($key) if (defined $cgih->param($key));
    }

    &set_tripSurvey(%survey);

    &db_disconnect();

    print "Location: index.cgi\n\n";

