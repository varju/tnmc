#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::cookie;
use tnmc::db;
use tnmc::general_config;

{
    #############
    ### Main logic
    
    &db_connect();

    cookie_get();

    my @params =  $tnmc_cgi->param();
        
    foreach my $key (@params) {
        my $val = $tnmc_cgi->param($key);
        &set_general_config($key, $val);
    }

    &db_disconnect();

    print "Location: index.cgi\n\n";
}
