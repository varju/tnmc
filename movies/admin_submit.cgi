#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::general_config;
use tnmc::cgi;


#############
### Main logic

&tnmc::security::auth::authenticate();
my $tnmc_cgi = &tnmc::cgi::get_cgih();

my @params =  $tnmc_cgi->param();

foreach my $key (@params) {
    my $val = $tnmc_cgi->param($key);
    &set_general_config($key, $val);
}

print "Location: index.cgi\n\n";


