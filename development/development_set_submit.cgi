#!/usr/bin/perl

##################################################################
#       Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

use lib '/tnmc';
use tnmc;
use tnmc::config;

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

        print "Location: $tnmc_url/development/\n\n";
