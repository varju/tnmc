#!/usr/bin/perl

use strict;
use CGI;

use lib '/tnmc';
use tnmc::db;
use tnmc::mail::parse;
use tnmc::mail::data;


db_connect();

my $cgih = new CGI;

my $raw = $cgih->param('raw');
my $auth = $cgih->param('auth');

print "Content-type: text/html\n\n";

if ($auth ne '424242') {
    print "Permission denied\n";
}
else {
    my $message_ref = message_parse($raw);
    
    # give this a blank id
    $$message_ref{'Id'} = 0;
    
    # figure out the userid
    my $UserId = message_lookup_user($$message_ref{'AddrTo'});
    
    if (defined $UserId) {
        $$message_ref{'UserId'} = $UserId;
    }
    
    message_store($message_ref);
    
    print "\n";
    print "To is ", $$message_ref{'AddrTo'}, "\n";
    print "From is ", $$message_ref{'AddrFrom'}, "\n";
    print "Date is ", $$message_ref{'Date'}, "\n";
    print "ReplyTo is ", $$message_ref{'ReplyTo'}, "\n";
    print "Body is ", $$message_ref{'Body'}, "\n";
}

db_disconnect();
