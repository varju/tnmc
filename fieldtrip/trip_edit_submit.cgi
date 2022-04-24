#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::user;
use tnmc::cgi;

require 'fieldtrip/FIELDTRIP.pl';

#############
### Main logic

&tnmc::db::db_connect();

@cols = &tnmc::db::db_get_cols_list('Fieldtrips');
foreach $key (@cols) {
    $trip{$key} = &tnmc::cgi::param($key);
}
&set_trip(%trip);

&tnmc::db::db_disconnect();

print "Location: index.cgi\n\n";

