#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
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
&tnmc::template::header();

$tripID = &tnmc::cgi::param(tripID);
&show_trip_all($tripID);

&tnmc::template::footer();
&tnmc::db::db_disconnect();

#######################################
sub show_trip_all {
    my ($tripID) = @_;

    my (%trip);
    &get_trip($tripID, \%trip);

    &tnmc::template::show_heading($trip{title});

    print qq{
        <table border="0" cellpadding="1" cellspacing="0">
        <tr><td valign="top">$trip{blurb}</td></tr>
        </table>
    };

}
