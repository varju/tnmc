#!/usr/bin/perl

##################################################################
# Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::cookie;
use tnmc::db;
use tnmc::user;

#############
### Main logic

db_connect();
cookie_get();

my $userID = $tnmc_cgi->param('userID');    
if ($userID) {
    &del_user($userID);
}

db_disconnect();

print "Location: index.cgi\n\n";
