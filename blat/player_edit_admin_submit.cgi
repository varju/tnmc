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

my @cols = &lib::db::db_get_cols_list('Players');
foreach $key (@cols) {
    $hash{$key} = $cgih->param($key);
}

&lib::blat::set_player(\%hash);
print "Location: index.cgi\n\n";

