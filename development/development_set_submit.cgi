#!/usr/bin/perl

##################################################################
#       Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::config;
use tnmc::security::auth;
use tnmc::db;
use tnmc::general_config;

#############
### Main logic

&db_connect();
&tnmc::security::auth::authenticate();

my @params = $tnmc_cgi->param();

foreach my $key (@params) {
    my $val = $tnmc_cgi->param($key);
    &set_general_config($key, $val);
}

&db_disconnect();

print "Location: /development/\n\n";
