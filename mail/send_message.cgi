#!/usr/bin/perl

use CGI;

use lib '/tnmc';
use strict;

use tnmc::config;
use tnmc::cookie;
use tnmc::db;

use tnmc::mail::data;
use tnmc::mail::send;

#############
### Main logic

db_connect();
cookie_get();

if ($USERID) {
    my %message;
    $message{AddrFrom} = $tnmc_cgi->param('AddrFrom');
    $message{AddrTo} = $tnmc_cgi->param('AddrTo');
    $message{Subject} = $tnmc_cgi->param('Subject');
    $message{Body} = $tnmc_cgi->param('Body');
    $message{UserId} = $USERID;
    $message{Sent} = 1;

    # save a copy locally
    message_store(\%message);

    # send a copy out
    message_send(\%message);
}
    
print "Location: /mail/\n\n";
    
db_disconnect();
