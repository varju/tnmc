#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';
use tnmc;
require 'fieldtrip/FIELDTRIP.pl';

    #############
    ### Main logic
    
    $cgih = new CGI;
    
    &db_connect();

    @cols = &db_get_cols_list('Fieldtrips');
     foreach $key (@cols)
    {
         $trip{$key} = $cgih->param($key);
    }
    &set_trip(%trip);
    
    &db_disconnect();

    print "Location: index.cgi\n\n";

