#!/usr/bin/perl

use CGI;

use lib '/tnmc';
use strict;

use tnmc::config;
use tnmc::cookie;
use tnmc::db;

use tnmc::mail::prefs;

#############
### Main logic

db_connect();
cookie_get();

if ($USERID) {
    my %prefs;
    $prefs{From} = $tnmc_cgi->param('From');

    mail_set_all_prefs($USERID,\%prefs);
}

print "Location: $tnmc_url/mail/\n\n";
    
db_disconnect();
