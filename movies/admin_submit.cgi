#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use CGI;

use lib '/usr/local/apache/tnmc';

use tnmc::db;
use tnmc::general_config;

    #############
    ### Main logic
    
    &db_connect();

    my $cgih = new CGI;
    my @params =  $cgih->param();
        
    foreach $_ (@params)
    {    my $val = $cgih->param($_);
        &set_general_config($_, $val);
        }

    &db_disconnect();

    print "Location: index.cgi\n\n";

