#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
#       Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::movies::movie;
use tnmc::cgi;

#############
### Main logic

&tnmc::security::auth::authenticate();

my $movieID = &tnmc::cgi::param('movieID');

if ($movieID) {
    &tnmc::movies::movie::del_movie($movieID);
}

print "Location: index.cgi\n\n";

