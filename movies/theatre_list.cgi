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
use tnmc::util::date;

#############
### Main logic

&tnmc::template::header();

my @theatres = &tnmc::movies::theatres::list_theatres();

print "<table>\n";
print "<tr>\n";
print "<th>TheatreID</th>\n";
print "<th>Name</th>\n";
print "<th>Mybc</th>\n";
print "<th>Google</th>\n";
print "<th>Cineplex</th>\n";
print "<th>Other</th>\n";
print "</tr>";

foreach my $theatreid (@theatres) {
    my $theatre      = &tnmc::movies::theatres::get_theatre($theatreid);
    my $next_tuesday = &tnmc::util::date::get_next_tuesday();
    print "<tr>\n";
    print "<td>$theatreid</td>\n";
    print "<td><a href=\"movies/theatre_edit_admin.cgi?theatreID=$theatreid\">$theatre->{'name'}</a></td>\n";
    print "<td>$theatre->{'mybcid'}</td>\n";
    print "<td><a href=\"http://www.google.com/movies?tid=$theatre->{'googleID'}\">$theatre->{'googleID'}</a></td>\n";
    print
"<td><a href=\"http://www.cineplex.com/Showtimes/any-movie/$theatre->{'cineplexID'}?Date=$next_tuesday\">$theatre->{'cineplexID'}</a></td>\n";
    print "<td>$theatre->{'otherid'}</td>\n";
    print "</tr>\n";
}

print "<tr>\n";
print "<td></td>\n";
print "<td><a href=\"movies/theatre_edit_admin.cgi?theatreID=0\">New theatre...</a></td>\n";
print "<td></td>\n";
print "</tr>\n";
print "</table>";

&tnmc::template::footer();
