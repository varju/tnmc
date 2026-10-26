#!/usr/bin/perl

##################################################################
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::user;
use tnmc::cgi;
use tnmc::config;

#############
### Main logic

&tnmc::db::db_connect();
&tnmc::security::auth::authenticate();

# only the logged-in user, and never the userID from the form
if ($USERID) {
    my @params = &tnmc::cgi::param();
    my $user   = &tnmc::user::get_user($USERID);

    foreach my $key (@params) {
        next if ($key eq "submit");
        next if ($key eq "x");
        next if ($key eq "y");
        next if ($key eq "");
        next if ($key eq "userID");
        next if ($key =~ /^group/);
        next if ($key eq "password" && !&tnmc::cgi::param($key));
        $user->{$key} = &tnmc::cgi::param($key);
    }
    &tnmc::user::set_user($user) unless $user->{username} eq 'demo';
}

&tnmc::db::db_disconnect();

print "Location: $tnmc_url/user/my_prefs.cgi\n\n";
