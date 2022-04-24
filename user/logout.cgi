#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::config;
use tnmc::db;
use tnmc::cgi;

#############
### Main logic

&tnmc::db::db_connect();

# boot the user.
&tnmc::security::auth::authenticate();
my $cookie = &tnmc::security::auth::logout();

my $location = $tnmc_url;
print &tnmc::cgi::redirect(
    -uri    => $location,
    -cookie => $cookie
);

&tnmc::db::db_disconnect();

##########################################################
#### The end.
##########################################################

