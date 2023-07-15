#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::db;
use tnmc::movies::movie;
use tnmc::cgi;

#############
### Main logic

my %movie;

my @cols = &tnmc::db::db_get_cols_list('Movies');

foreach my $key (@cols) {
    $movie{$key} = &tnmc::cgi::param($key);
}
&tnmc::movies::movie::set_movie(%movie);

print "Location: index.cgi\n\n";

