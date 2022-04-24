#!/usr/bin/perl

##################################################################
#     Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::movies::attendance;
use tnmc::cgi;

#############
### Main logic

&tnmc::security::auth::authenticate();

# get the userid
my $userID = &tnmc::cgi::param('userID');

# get each field
my @params = &tnmc::cgi::param();

foreach my $key (@params) {
    next unless $key =~ /^night_(.*)$/;
    my $nightID    = $1;
    my %attendance = (
        'userID'  => $userID,
        'nightID' => $nightID,
        'type'    => &tnmc::cgi::param($key)
    );
    &tnmc::movies::attendance::set_attendance(\%attendance);
}

# get the default
my $default = &tnmc::cgi::param('movieAttendDefault');

print "Location: $ENV{HTTP_REFERER}\n\n";

