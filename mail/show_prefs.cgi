#!/usr/bin/perl

use CGI;

use lib '/tnmc';
use strict;

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;

use tnmc::mail::prefs::data;
use tnmc::mail::prefs::template;

#############
### Main logic

db_connect();
header();

if ($USERID) {
    show_heading('mail prefs');

    my $prefs_ref = mail_get_all_prefs($USERID);
    messages_print_prefs($prefs_ref);
}
    
footer();
db_disconnect();
