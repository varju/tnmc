#!/usr/bin/perl

##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::movies::faction;
use tnmc::cgi;

#############
### Main logic

&tnmc::security::auth::authenticate();

my @cols = &db_get_cols_list('MovieFactions');

my %faction;
foreach my $key (@cols){
    $faction{$key} = &tnmc::cgi::param($key);
}

&tnmc::movies::faction::set_faction(\%faction);

print "Location: factions.cgi\n\n";
