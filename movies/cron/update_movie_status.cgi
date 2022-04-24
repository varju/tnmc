#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::db;
use tnmc::general_config;
use tnmc::movies::movie;
use tnmc::movies::night;
use tnmc::movies::faction;

#############
### Main logic

my $dbh = &tnmc::db::db_connect();

my $sql = "SELECT NOW()";
my $sth = $dbh->prepare($sql);
$sth->execute();
my ($timestamp) = $sth->fetchrow_array();
$sth->finish;

#
# This script should get run every tuesday evening at about 10 pm
# (or just after we watch the movie).
#

#
# (1) Set this week's movie to "seen"
#

my @nights = &tnmc::movies::night::list_active_nights();

foreach my $nightID (@nights) {

    my %night;
    &tnmc::movies::night::get_night($nightID, \%night);

    my $movieID = $night{'movieID'};
    my %movie;
    &tnmc::movies::movie::get_movie($movieID, \%movie);
    $movie{'statusSeen'} = "1";
    $movie{'date'}       = $timestamp;
    &tnmc::movies::movie::set_movie(%movie);

}

#
# (2) Set last week's new releases to just "showing"
#     Set last week's banned movies to normal
#

$sql = "UPDATE Movies SET statusNew = '0' WHERE statusShowing = '1'";
$sth = $dbh->prepare($sql);
$sth->execute();
$sth->finish;

$sql = "UPDATE Movies SET statusBanned = '0'";
$sth = $dbh->prepare($sql);
$sth->execute();
$sth->finish;

#
# (3) Make an extra night off in the future - night row
#
# Note that this must be run on a Tuesday because of the NOW() code
#

my $numberOfWeeksToShow = 3;

### Factions
my @factions = &tnmc::movies::faction::list_factions();
foreach my $factionID (@factions) {

    my $faction = &tnmc::movies::faction::get_faction($factionID);

    # night creation
    if ($faction->{'night_creation'}) {
        foreach (my $i = 1 ; $i <= $numberOfWeeksToShow ; $i++) {

            # get the date for the $i-th night from now.

            $sql = "SELECT DATE_FORMAT(DATE_ADD(NOW(), INTERVAL ? DAY), '%Y-%m-%d' )";
            $sth = $dbh->prepare($sql);
            $sth->execute($i * 7);
            my ($i_date) = $sth->fetchrow_array();
            $sth->finish();

            print "$i_date\n";

            # next if the night already exists
            next if &tnmc::movies::night::list_nights([], "WHERE factionID = $factionID AND date LIKE '$i_date%'", "");

            # add the night
            my %night = (
                nightID        => 0,
                factionID      => $factionID,
                godID          => $faction->{'godID'},
                valid_theatres => $faction->{'theatres'},
                date           => "$i_date 23:00:00"
            );
            &tnmc::movies::night::set_night(%night);
            print "add $i_date\n";
        }
    }
}

# the end.
&tnmc::db::db_disconnect();
