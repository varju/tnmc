#!/usr/bin/perl

use AutoSplit;
use strict;

my @modules = `find /tnmc/tnmc -type f | grep -v CVS | grep -v \\~ | grep \\.pm\\\$`;

print "Autospliting $#modules modules...\n";

foreach my $module (@modules){
    chomp $module;
    autosplit($module, "/tnmc/auto", 0, 1, 1);
}
