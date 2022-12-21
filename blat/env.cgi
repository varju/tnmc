#!/usr/bin/perl

use strict;

use lib::cgi;

print "Content-Type: text/html; charset=utf-8\n\n";
print qq{
    <head>
    <title>TNMC Environment Variables and Form Tester.</title>
    </head>
    };

### date stuff.
my $today;
open(DATE, "/bin/date +%Y%m%d%H |");
while (<DATE>) {
    chomp;
    $today = $_;
}
close(DATE);

print qq{
    <b>Date/Time</b> $today<p>
    };

### INClude list
print "<p><b><font color=\"0000ff\">\@INC:</font></b><br>\n";
foreach my $key (@INC) {
    print "$key<br>";
}

### ENV variables
print "<p><b><font color=\"0000ff\">ENV list:</font></b><br> ";
foreach my $var (sort keys %ENV) {
    print "<b>$var</b> $ENV{$var}<br>";
}

### ENV dump
print "<p><b><font color=\"0000ff\">ENV dump:</font></b><br> ";
print %ENV;

db_disconnect();
