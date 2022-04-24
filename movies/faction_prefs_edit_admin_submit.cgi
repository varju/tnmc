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

my @cols = &tnmc::db::db_get_cols_list('MovieFactionPrefs');

my %prefs;
foreach my $key (@cols) {
    $prefs{$key} = &tnmc::cgi::param($key);
}

&tnmc::movies::faction::save_faction_prefs(\%prefs);

print "Location: factions.cgi\n\n";
