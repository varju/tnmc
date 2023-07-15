#!/usr/bin/perl

##################################################################
#       Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use warnings;

use lib '/tnmc';

use tnmc::db;
use tnmc::pics::pic;

my ($sql, $sth);

$sql = "SELECT picID from Pics";
$sth = $dbh_tnmc->prepare($sql);
$sth->execute();

while (my @row = $sth->fetchrow_array) {
    $picID = $row[0];

    print $picID, "\n";

    # &tnmc::pics::pic::update_cache($picID);
    &tnmc::pics::pic::update_cache_pub($picID);

}

