#!/usr/bin/perl

##################################################################
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::user;

#############
### Main logic

&db_connect();

&tnmc::security::auth::authenticate();

my @cols = &db_get_cols_list('Personal');

my %user;
foreach my $key (@cols) {
    $user{$key} = $tnmc_cgi->param($key);
}
&set_user(%user);

&db_disconnect();

print "Location: index.cgi\n\n";

