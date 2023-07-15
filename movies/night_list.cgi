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
            <th>nightID</th>
            <th>date</th>
            <th>factionID</th>
            <th>movieID</th>
        </tr>
};

foreach my $nightID (@nights) {
    my %night;
    &tnmc::movies::night::get_night($nightID, \%night);
    my $movieID = $night{'movieID'};
    if (!defined($movieID) || !$movieID) {
        $movieID = '';
    } else {
        $movieID = "<a href='/movies/movie_view.cgi?movieID=$movieID'>$movieID</a>";
    }
    print qq{
        <tr>
            <td>$nightID</td>
            <td><a href="movies/night_edit_admin.cgi?nightID=$nightID">$night{date}</a></td>
            <td>$night{'factionID'}</td>
            <td>$movieID</td>
        </tr>
    };
}

print "</table>";

&tnmc::template::footer();

