#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca         
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::cookie;
use tnmc::config;
use tnmc::db;

#############
### Main logic

db_connect();

# retrieve the old cookie
cookie_get();

my $userID = $tnmc_cookie_in{'userID'};
cookie_revoke();

my $cookie = cookie_tostring();

my $location = $tnmc_url . '/';
print $tnmc_cgi->redirect(
                          -uri=>$location,
                          -cookie=>$cookie);

db_disconnect();

##########################################################
#### The end.
##########################################################

