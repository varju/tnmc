#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::template;
use tnmc::movies::movie;
use tnmc::movies::night;

#############
### Main logic

&tnmc::template::header();

my @nights;

&tnmc::movies::night::list_nights(\@nights, "", "ORDER BY date DESC");

&tnmc::template::show_heading("Nights");

print qq{
    <table>
        <tr>
            <th>nightID
            <th>date
            <th>factionID
            <th>movieID
        </tr>
};

foreach my $nightID (@nights) {
    my %night;
    &tnmc::movies::night::get_night($nightID, \%night);
    print qq{
        <tr>
        <td> $nightID
        <td><a href="movies/night_edit_admin.cgi?nightID=$nightID">$night{date}</a>
        <td> $night{'factionID'}
        <td> $night{'movieID'}
            <br>
    };
}

print "</table>";

&tnmc::template::footer();

