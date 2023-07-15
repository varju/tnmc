#!/usr/bin/perl

##################################################################
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::user;
use tnmc::cgi;

#############
### Main logic

&tnmc::db::db_connect();

&tnmc::security::auth::authenticate();

my @cols = &tnmc::db::db_get_cols_list('Personal');

my %user;
foreach my $key (@cols) {
    $user{$key} = &tnmc::cgi::param($key);
}
&tnmc::user::set_user(\%user);

&tnmc::db::db_disconnect();

print "Location: index.cgi\n\n";

