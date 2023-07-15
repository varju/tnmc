#!/usr/bin/perl

use strict;
use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::cgi;

&tnmc::db::db_connect();
&tnmc::security::auth::authenticate();

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

### form data
print "\n<p><b><font color=\"0000ff\">Form Data:</font></b><br>\n";

my @names = &tnmc::cgi::param();
print @names;

print "<p> ";
foreach my $name (@names) {
    my $value = &tnmc::cgi::param($name);
    print "<b>$name</b> : $value<br>";
}

print "\n<p><b><font color=\"0000ff\">Query Data:</font></b><br>\n";

my @names = &tnmc::cgi::url_param();
print @names;

print "<p> ";
foreach my $name (@names) {
    my $value = &tnmc::cgi::url_param($name);
    print "<b>$name</b> : $value<br>";
}

### Cookies
print "\n<p><b><font color=\"0000ff\">Cookies:</font></b><br>\n";

my @cookies = &tnmc::cgi::cookie();
foreach my $cookie (@cookies) {
    print "<b><u>$cookie</u></b><br>";
    my %cookie = &tnmc::cgi::cookie($cookie);
    print %cookie;
    print "<br>\n";
    foreach my $var (sort keys %cookie) {
        print "<b>$var</b> $cookie{$var}<br>";
    }
    print "<p>";
}

### ENV variables
print "<p><b><font color=\"0000ff\">ENV list:</font></b><br> ";
foreach my $var (sort keys %ENV) {
    print "<b>$var</b> $ENV{$var}<br>";
}

### ENV dump
print "<p><b><font color=\"0000ff\">ENV dump:</font></b><br> ";
print %ENV;

&tnmc::db::db_disconnect();
