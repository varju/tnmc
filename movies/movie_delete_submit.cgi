#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
#       Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/usr/local/apache/tnmc';

use tnmc::db;
use tnmc::movies::movie;

    #############
    ### Main logic

    my $cgih = new CGI;
    my $movieID = $cgih->param('movieID');    
    
    if ($movieID)
    {     &db_connect();
        &del_movie($movieID);
        &db_disconnect();
    }

    print "Location: index.cgi\n\n";

