#!/usr/bin/perl

##################################################################
#       Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

use lib '/usr/local/apache/tnmc/';
use tnmc;

        #############
        ### Main logic
        
        $cgih = new CGI;
        
        &db_connect();

        @params =  $cgih->param();
        
        foreach $_ (@params)
        {       $val = $cgih->param($_);
                &set_general_config($_, $val);
        }

        &db_disconnect();

        print "Location: http://tnmc.dhs.org/development/\n\n";
