#!/usr/bin/perl

##################################################################
#     Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::cookie;
use tnmc::db;
use tnmc::movies::attend;

{
    #############
    ### Main logic

    &db_connect();
    
    cookie_get();

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
