#!/usr/bin/perl

use CGI;

use lib '/tnmc';
use strict;

use tnmc::cookie;
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

    my %message;
    $message{AddrFrom} = mail_get_email_address($USERID);
    message_print_compose(\%message);
}
    
footer();
db_disconnect();
