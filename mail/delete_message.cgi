#!/usr/bin/perl

use CGI;

use lib '/tnmc';
use strict;

use tnmc::config;
use tnmc::security::auth;
use tnmc::db;

use tnmc::mail::data;

#############
### Main logic

db_connect();
&tnmc::security::auth::authenticate();

if ($USERID) {
    my $Id = $tnmc_cgi->param('Id');
    delete_message($USERID,$Id);
}
    
print "Location: /mail/\n\n";

db_disconnect();
