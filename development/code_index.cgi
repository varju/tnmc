#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::template;

&header();

my @files1 = `find /tnmc/ -maxdepth 2 -type f | grep cgi\\\$`;
my @files2 = `find /tnmc/tnmc -maxdepth 3 -type f | grep pm\\\$`;


foreach my $file (@files1, @files2){
    chomp $file;
    print "<a href=\"code_view.cgi?file=$file\">$file</a><br>";
}

&footer();
