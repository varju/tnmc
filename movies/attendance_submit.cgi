#!/usr/bin/perl

##################################################################
#     Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::movies::attend;
use tnmc::cgi;

{
    #############
    ### Main logic

    &db_connect();
    
    &tnmc::security::auth::authenticate();
    my $tnmc_cgi = &tnmc::cgi::get_cgih();

    my %attendance = {};
    # get each field
    my @params =  $tnmc_cgi->param();
    foreach my $key (@params){
        next unless $key =~ /^movie/;
        $attendance{$key} = $tnmc_cgi->param($key);
    }
    
    # get the userid 
    $attendance{userID} = $tnmc_cgi->param('userID');
    
    # send it to the db.
    &set_attendance(%attendance);
    
    print "Location: $ENV{HTTP_REFERER}\n\n";
    
    &db_disconnect();
}
