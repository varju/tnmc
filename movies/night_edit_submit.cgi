#!/usr/bin/perl

##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::cookie;
use tnmc::db;
use tnmc::movies::night;

{
    #############
    ### Main logic
    
    &db_connect();

    cookie_get();

    my @cols = &db_get_cols_list('MovieNights');

    my %night;
    foreach my $key (@cols){
        $night{$key} = $tnmc_cgi->param($key);
    }
    
    &set_night(%night);
    
    &db_disconnect();
    
    print "Location: admin.cgi\n\n";
}
