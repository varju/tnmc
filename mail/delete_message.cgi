#!/usr/bin/perl

use CGI;

use lib '/tnmc';
use strict;

use tnmc::config;
use tnmc::cookie;
use tnmc::db;

use tnmc::mail::data;

#############
### Main logic

db_connect();
cookie_get();

if ($USERID) {
    my $Id = $tnmc_cgi->param('Id');
    delete_message($USERID,$Id);
}
    
print "Location: $tnmc_url/mail/\n\n";

db_disconnect();
