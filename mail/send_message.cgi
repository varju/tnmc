#!/usr/bin/perl

use lib '/tnmc';
use strict;

use tnmc::config;
use tnmc::security::auth;
use tnmc::cgi;

use tnmc::mail::data;
use tnmc::mail::send;

#############
### Main logic

&tnmc::security::auth::authenticate();
my $tnmc_cgi = &tnmc::cgi::get_cgih();

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
