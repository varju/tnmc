#!/usr/bin/perl

##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::movies::night;
use tnmc::cgi;

#############
### Main logic

&tnmc::security::auth::authenticate();

my @cols = &tnmc::db::db_get_cols_list('MovieNights');

my %night;
foreach my $key (@cols) {
    $night{$key} = &tnmc::cgi::param($key);
}

&tnmc::movies::night::set_night(%night);

print "Location: index.cgi\n\n";
