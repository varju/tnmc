#!/usr/bin/perl

use CGI;

use lib '/tnmc';
use strict;

use tnmc::cookie;
use tnmc::db;
use tnmc::template;

use tnmc::mail::data;

#use tnmc::mail::template;

#############
### Main logic

db_connect();
header();

if ($USERID) {
    show_heading('mail');

    my $messages_ref = get_message_list($USERID);

    print "<table>\n";
    print "<tr>\n";
    print "  <td><b>id</b></td>\n";
    print "  <td><b>from</b></td>\n";
    print "  <td><b>date</b></td>\n";
    print "  <td><b>subject</b></td>\n";
    print "</tr>\n";

    foreach my $msg (@$messages_ref) {
        print "<tr>\n";
        print "  <td>", $$msg{Id}, "</td>\n";
        print "  <td>", $$msg{AddrFrom}, "</td>\n";
        print "  <td>", $$msg{Date}, "</td>\n";
        print "  <td>", $$msg{Subject}, "</td>\n";
        print "</tr>\n";
    }

    print "</table>\n";

#    messages_print($messages_ref);
}
    
footer();
db_disconnect();
