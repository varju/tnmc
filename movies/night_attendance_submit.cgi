#!/usr/bin/perl

##################################################################
#     Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::movies::attendance;
use tnmc::cgi;

{
    #############
    ### Main logic

    &db_connect();
    
    &tnmc::security::auth::authenticate();
    my $tnmc_cgi = &tnmc::cgi::get_cgih();
    
    # get the userid 
    my $userID = $tnmc_cgi->param('userID');
    
    # get each field
    my @params =  $tnmc_cgi->param();
    
    foreach my $key (@params){
        next unless $key =~ /^night_(.*)$/;
        my $nightID = $1;
        my %attendance = 
            ( 'userID' => $userID,
              'nightID' => $nightID,
              'type' => $tnmc_cgi->param($key)
              );
        &set_attendance(\%attendance);
    }
    
    # get the default
    my $default = $tnmc_cgi->param('movieAttendDefault');
    
    print "Location: $ENV{HTTP_REFERER}\n\n";
    
    &db_disconnect();
}
