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

my $nightID = $tnmc_cgi->param('nightID');

## update the night with submitted vals.
if ($nightID){
    my %night;
    &get_night($nightID, \%night);
    
    foreach my $key (keys %night){
        my $val =  $tnmc_cgi->param($key);
        $night{$key} = $val if(defined $val);
    }
    
    &set_night(%night);
}

my $location = $tnmc_cgi->param('LOCATION') || "/movies/";
print "Location: $location\n\n";
