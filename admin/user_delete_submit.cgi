#!/usr/bin/perl

##################################################################
# Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

use lib '/usr/local/apache/tnmc';
use tnmc;

require 'basic_testing_tools.pl';


    #############
    ### Main logic

    $cgih = new CGI;
    $userID = $cgih->param('userID');    
    
    if ($userID)
    {     &db_connect();
        &del_user($userID);
        &db_disconnect();
    }

    print "Location: index.cgi\n\n";

