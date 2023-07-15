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
    <title>TNMC Environment Variables</title>
    <style>
    th {
      text-align: left;
    }
    </style>
    </head>
    };

### INClude list
print "<p><b><font color=\"0000ff\">\@INC:</font></b><br>\n";
foreach my $key (@INC) {
    print "$key<br>";
}

### Cookies
print "\n<p><b><font color=\"0000ff\">Cookies:</font></b><br>\n";
my @cookies = &tnmc::cgi::cookie();
foreach my $cookie (@cookies) {
    print "<b><u>$cookie</u></b><br>";
    print "<table>";
    my %cookie = &tnmc::cgi::cookie($cookie);
    foreach my $var (sort keys %cookie) {
        print "<tr><th>$var</th><td>$cookie{$var}</td></tr>\n";
    }
    print "</table>";
}

### ENV variables
print "<p><b><font color=\"0000ff\">ENV list:</font></b><br> ";
print "<table>";
foreach my $var (sort keys %ENV) {
    print "<tr><th>$var</th><td>$ENV{$var}</td></tr>\n";
}
print "</table>";

&tnmc::db::db_disconnect();
