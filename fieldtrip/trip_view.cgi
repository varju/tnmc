#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca         
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

use lib '/tnmc';
use tnmc;
require 'fieldtrip/FIELDTRIP.pl';

#############
### Main logic

&db_connect();
&header();

$cgih = new CGI;
$tripID = $cgih->param(tripID);
&show_trip_all($tripID);

&footer();
db_disconnect();


#######################################
sub show_trip_all{
    my ($tripID) = @_;
    
    my (%trip);
    &get_trip($tripID, \%trip);

    &show_heading($trip{title});
        
    print qq{
        <table border="0" cellpadding="1" cellspacing="0">
        <tr><td valign="top">$trip{blurb}</td></tr>
        </table>
    };


}
