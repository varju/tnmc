#!/usr/bin/perl

##################################################################
# Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::user;
use tnmc::cgi;

#############
### Main logic

db_connect();
&tnmc::security::auth::authenticate();
my $tnmc_cgi = &tnmc::cgi::get_cgih();

my $userID = $tnmc_cgi->param('userID');    
if ($userID) {
    &del_user($userID);
}

db_disconnect();

print "Location: index.cgi\n\n";
