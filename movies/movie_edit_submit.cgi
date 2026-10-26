#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::movies::movie;
use tnmc::cgi;

#############
### Main logic

&tnmc::security::auth::authenticate();

my %movie;

my @cols = &tnmc::db::db_get_cols_list('Movies');

# only set submitted fields, so db_set_row keeps the rest
foreach my $key (@cols) {
    my $value = &tnmc::cgi::param($key);
    $movie{$key} = $value if defined $value;
}
&tnmc::movies::movie::set_movie(%movie);

print "Location: index.cgi\n\n";

