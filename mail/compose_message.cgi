#!/usr/bin/perl

use lib '/tnmc';
use strict;

use tnmc::security::auth;
use tnmc::template;

use tnmc::mail::data;
use tnmc::mail::template;

#############
### Main logic

header();

if ($USERID) {
    show_heading('mail');

    my %message;
    $message{AddrFrom} = mail_get_email_address($USERID);

    message_print_compose(\%message);
}
    
footer();
