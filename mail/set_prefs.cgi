#!/usr/bin/perl

use lib '/tnmc';
use strict;

use tnmc::config;
use tnmc::security::auth;
use tnmc::cgi;

use tnmc::mail::prefs::data;

#############
### Main logic

&tnmc::security::auth::authenticate();

if ($USERID) {
    my %prefs;
    $prefs{From} = &tnmc::cgi::param('From');
    $prefs{FromAddr} = &tnmc::cgi::param('FromAddr');
    $prefs{Quote} = &tnmc::cgi::param('Quote');

    mail_set_all_prefs($USERID,\%prefs);
}

print "Location: /mail/\n\n";
