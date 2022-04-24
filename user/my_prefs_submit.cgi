#!/usr/bin/perl

##################################################################
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::user;
use tnmc::cgi;
use tnmc::config;

#############
### Main logic

&tnmc::db::db_connect();
&tnmc::security::auth::authenticate();

my @params = &tnmc::cgi::param();
my $userID = &tnmc::cgi::param('userID');
my $user   = &tnmc::user::get_user($userID);

foreach my $key (@params) {
    next if ($key eq "submit");
    next if ($key eq "x");
    next if ($key eq "y");
    next if ($key eq "");
    $user->{$key} = &tnmc::cgi::param($key);
}
&tnmc::user::set_user($user);

&tnmc::db::db_disconnect();

print "Location: $tnmc_url/user/my_prefs.cgi\n\n";
