#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca         
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

use strict;
use lib '/usr/local/apache/tnmc';

use tnmc::cookie;
use tnmc::config;
use tnmc::db;

#############
### Main logic

my $tnmc_cgi = new CGI;

# retrieve the old cookie
get_cookie();

my $userID = $tnmc_cookie_in{'userID'};
$tnmc_cookie_in{'logged-in'} = '0';

my $cookie = $tnmc_cgi->cookie(
                               -name=>'TNMC',
                               -value=>\%tnmc_cookie_in,
                               -expires=>'+1y',
                               -path=>'/',
                               -domain=>$tnmc_hostname,
                               -secure=>'0'
                               );

my $location = $tnmc_url . '/index.cgi';
print $tnmc_cgi->redirect(
                          -uri=>$location,
                          -cookie=>$cookie);

##########################################################
#### The end.
##########################################################

