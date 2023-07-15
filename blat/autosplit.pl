#!/usr/bin/perl

use AutoSplit;
use strict;
use warnings;

my @modules = `find . -type f | grep -v CVS | grep -v \\~ | grep \\.pm\\\$`;

print "Autospliting $#modules modules...\n";

foreach my $module (@modules) {
    chomp $module;
    autosplit($module, "./auto/", 0, 1, 1);
}
