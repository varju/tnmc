#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
#       Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::movies::movie;
use tnmc::cgi;

#############
### Main logic

my $cgih = &tnmc::cgi::get_cgih();
my $movieID = $cgih->param('movieID');    

if ($movieID) {
    &del_movie($movieID);
}

print "Location: index.cgi\n\n";

