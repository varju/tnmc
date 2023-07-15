#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::general_config;
use tnmc::cgi;

#############
### Main logic

&tnmc::security::auth::authenticate();

my @params = &tnmc::cgi::param();

foreach my $key (@params) {
    my $val = &tnmc::cgi::param($key);
    &tnmc::general_config::set_general_config($key, $val);
}

print "Location: index.cgi\n\n";

