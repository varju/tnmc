#!/usr/bin/perl

##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::movies::theatres;
use tnmc::cgi;

#############
### Main logic

&tnmc::security::auth::authenticate();

my @cols = &tnmc::db::db_get_cols_list('MovieTheatres');

my %hash;
foreach my $key (@cols) {
    $hash{$key} = &tnmc::cgi::param($key);
}

&tnmc::movies::theatres::set_theatre(\%hash);

print "Location: theatre_list.cgi\n\n";
