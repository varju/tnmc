#!/usr/bin/perl

##################################################################
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::security::session;
use tnmc::db;
use tnmc::cgi;

#############
### Main logic

&db_connect();

&tnmc::security::auth::authenticate();
my $cgih = &tnmc::cgi::get_cgih();

my @cols = &db_get_cols_list('SessionInfo');

my %session;
foreach my $key (@cols) {
    $session{$key} = $cgih->param($key);
}
&tnmc::security::session::set_session(\%session);

&db_disconnect();

print "Location: index.cgi\n\n";

