#!/usr/bin/perl

##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::movies::night;
use tnmc::cgi;

#############
### Main logic

&tnmc::security::auth::authenticate();
my $tnmc_cgi = &tnmc::cgi::get_cgih();

my @cols = &db_get_cols_list('MovieNights');

my %night;
foreach my $key (@cols){
    $night{$key} = $tnmc_cgi->param($key);
}

&set_night(%night);

print "Location: admin.cgi\n\n";
