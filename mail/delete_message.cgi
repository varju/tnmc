#!/usr/bin/perl

use lib '/tnmc';
use strict;

use tnmc::config;
use tnmc::security::auth;
use tnmc::cgi;

use tnmc::mail::data;

#############
### Main logic

&tnmc::security::auth::authenticate();

if ($USERID) {
    my $Id = &tnmc::cgi::param('Id');
    delete_message($USERID,$Id);
}
    
print "Location: /mail/\n\n";
