#!/usr/bin/perl

use CGI;

use lib '/tnmc';
use strict;

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;

use tnmc::mail::data;
use tnmc::mail::template;

#############
### Main logic

db_connect();
header();

if ($USERID) {
    show_heading('mail');

    my $Id = $tnmc_cgi->param('Id');
    my $message_ref = get_message($USERID,$Id);
    message_print($message_ref);
}
    
footer();
db_disconnect();
