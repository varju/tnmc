#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::db;
use tnmc::movies::movie;

{
    #############
    ### Main logic
    
    my %movie;
    my $cgih = new CGI;
    
    &db_connect();

    my @cols = &db_get_cols_list('Movies');
    foreach my $key (@cols)
    {
        $movie{$key} = $cgih->param($key);
    }
    &set_movie(%movie);
    
    &db_disconnect();

    print "Location: index.cgi\n\n";
}
