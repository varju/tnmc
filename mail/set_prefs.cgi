#!/usr/bin/perl

use CGI;

use lib '/tnmc';
use strict;

use tnmc::config;
use tnmc::security::auth;
use tnmc::db;

use tnmc::mail::prefs::data;

#############
### Main logic

db_connect();
&tnmc::security::auth::authenticate();

if ($USERID) {
    my %prefs;
    $prefs{From} = $tnmc_cgi->param('From');
    $prefs{FromAddr} = $tnmc_cgi->param('FromAddr');
    $prefs{Quote} = $tnmc_cgi->param('Quote');

    mail_set_all_prefs($USERID,\%prefs);
}

print "Location: /mail/\n\n";
    
db_disconnect();
