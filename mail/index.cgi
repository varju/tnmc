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

    my $messages_ref = get_message_list($USERID);

    messages_print_list($messages_ref);
}
    
footer();
db_disconnect();
