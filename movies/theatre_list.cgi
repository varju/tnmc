#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc/';

use tnmc::template;
use tnmc::movies::movie;
use tnmc::movies::theatres;


#############
### Main logic

&header();

my @theatres = &tnmc::movies::theatres::list_theatres();

print "<table><tr><th>TheatreID</th><th>Name</th><th>Mybc</th></tr>";
foreach my $theatreid ( @theatres){
    my $theatre =  &tnmc::movies::theatres::get_theatre($theatreid);
    print "<tr><td>$theatreid</td><td><a href=\"theatre_edit_admin.cgi?theatreID=$theatreid\">$theatre->{'name'}</a></td><td>$theatre->{'mybcid'}</td></tr>\n";
}


print "<tr><td></td><td><a href=\"theatre_edit_admin.cgi?theatreID=0\">New theatre...</a></td><td></td></tr>\n";
print "</table>";

&footer();

