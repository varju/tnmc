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
my $tnmc_cgi = &tnmc::cgi::get_cgih();

if ($USERID) {
    my %prefs;
    $prefs{From} = $tnmc_cgi->param('From');
    $prefs{FromAddr} = $tnmc_cgi->param('FromAddr');
    $prefs{Quote} = $tnmc_cgi->param('Quote');

    mail_set_all_prefs($USERID,\%prefs);
}

print "Location: /mail/\n\n";
