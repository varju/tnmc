#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::db;
use tnmc::message;
use tnmc::cgi;
use tnmc::security::auth;
use tnmc::config;

#############
### Main logic

my %msg;

my @cols = &tnmc::db::db_get_cols_list('MessageMsg');

foreach my $key (@cols){
    $msg{$key} = &tnmc::cgi::param($key);
}

$msg{sender} = $tnmc::security::auth::USERID;
$msg{msgID} = 0;

&tnmc::message::set_msg(\%msg);

my $location = &tnmc::cgi::param('location') || "index.cgi";

print "Location: $tnmc_url$location\n\n";

