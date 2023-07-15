#!/usr/bin/perl

##################################################################
# Jeff Steinbok - steinbok@interchange.ubc.ca
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

my $userID = &tnmc::cgi::param('userID');
if ($userID) {
    &tnmc::user::del_user($userID);
}

&tnmc::db::db_disconnect();

print "Location: index.cgi\n\n";
