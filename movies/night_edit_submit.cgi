#!/usr/bin/perl

##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::movies::night;
use tnmc::cgi;

#############
### Main logic

&tnmc::security::auth::authenticate();

my $nightID = &tnmc::cgi::param('nightID');

## update the night with submitted vals.
if ($nightID) {
    my %night;
    &tnmc::movies::night::get_night($nightID, \%night);

    foreach my $key (keys %night) {
        my $val = &tnmc::cgi::param($key);
        $night{$key} = $val if (defined $val);
    }

    &tnmc::movies::night::set_night(%night);
}

my $location = &tnmc::cgi::param('LOCATION') || "/movies/";
print "Location: $location\n\n";
