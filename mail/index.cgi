#!/usr/bin/perl

use lib '/tnmc';
use strict;

use tnmc::security::auth;
use tnmc::template;
use tnmc::cgi;

use tnmc::mail::data;
use tnmc::mail::template;

#############
### Main logic

header();

if ($USERID) {
    show_heading('mail');

    my $messages_ref = get_message_list($USERID);

    messages_print_list($messages_ref);
}
    
footer();
