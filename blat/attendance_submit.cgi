#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use warnings;

use lib::db;
use lib::blat;
use lib::template;
use lib::cgi;

#############
### Main logic

my %hash;

my @params = $cgih->param();

foreach $key (@params) {
    next if ($key !~ /^attendance_(\d+)_(\d+)/);
    my $playerid = $1;
    my $gameid   = $2;
    my $val      = $cgih->param($key);
    $hash{$key} = $cgih->param($key);

    my %hash = (
        'playerid' => $playerid,
        'gameid'   => $gameid,
        'type'     => $val
    );

    &lib::blat::set_attendance(\%hash);
}

print "Location: index.cgi?\n\n";

