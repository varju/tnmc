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

#############
### Main logic

&db_connect();

my $sql = "SELECT NOW()";
my $sth = $dbh_tnmc->prepare($sql);
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

my @nights = list_active_nights();

foreach my $nightID (@nights){
    
    my %night;
    &get_night($nightID, \%night);
    
    my $movieID = $night{'movieID'};
    my %movie;
    &get_movie($movieID, \%movie);
    $movie{'statusSeen'} = "1";
    $movie{'date'} = $timestamp;
    &set_movie(%movie);
    
}

#
# (2) Set last week's new releases to just "showing"
#     Set last week's banned movies to normal
#

$sql = "UPDATE Movies SET statusNew = '0' WHERE statusShowing = '1'";
$sth = $dbh_tnmc->prepare($sql);
$sth->execute();
$sth->finish;


$sql = "UPDATE Movies SET statusBanned = '0'";
$sth = $dbh_tnmc->prepare($sql);
$sth->execute();
$sth->finish;

#
# (3) Advance the MovieAttendance Dates.
#     Make an extra night off in the future - attendance column (HACK)
#     Make an extra night off in the future - night row
#

my $numberOfWeeksToShow = 3;

# attendance crud
if (1 == 1){
    # $sql = "SELECT DATE_ADD(NOW(), INTERVAL ((9 - DATE_FORMAT(NOW(), 'w') ) % 7) DAY)";
    # $sth = $dbh_tnmc->prepare($sql);
    # $sth->execute();
    # ($this_tuesday) = $sth->fetchrow_array();
    # $sth->finish();
    
    my $span = 7 * $numberOfWeeksToShow;
    
    $sql = "SELECT DATE_ADD(NOW(), INTERVAL '$span' DAY)";
    $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();
    my ($far_tuesday) = $sth->fetchrow_array();
    $sth->finish();
       
    $sql = "SELECT DATE_FORMAT(NOW(), '%Y%m%d'), DATE_FORMAT('$far_tuesday', '%Y%m%d')";
    $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();
    my ($oldMovieDate, $newMovieDate) = $sth->fetchrow_array();
    $sth->finish();

    $sql = "ALTER TABLE MovieAttendance ADD movie$newMovieDate char(20), DROP COLUMN movie$oldMovieDate";
    $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();
    $sth->finish();
    
    # $sql = "UPDATE MovieAttendance SET movie$newMovieDate = 'Default'";
    # $sth = $dbh_tnmc->prepare($sql);
    # $sth->execute();
    # $sth->finish();
}

# nights
foreach (my $i = 1; $i <= $numberOfWeeksToShow; $i++){
    
    # get the date for the $i-th night from now.
    
    $sql = "SELECT DATE_FORMAT(DATE_ADD(NOW(), INTERVAL ? DAY), '%Y-%m-%d' )";
    $sth = $dbh_tnmc->prepare($sql);
    $sth->execute($i * 7);
    my ($i_date) = $sth->fetchrow_array();
    $sth->finish();

    print "$i_date\n";

    # next if the night already exists
    next if list_nights([], "WHERE date LIKE '$i_date%'", "");

    # add the night
    my %night = (
                 nightID => 0,
                 godID => 1,
                 date => "$i_date 23:00:00");
    set_night(%night);
    print "add $i_date\n";
}


# the end.
&db_disconnect();
