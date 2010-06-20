package tnmc::movies::cron;

use strict;

use tnmc::db;

sub reset_status_showing
{
    my $dbh = &tnmc::db::db_connect();
    my $sql = "UPDATE Movies SET statusShowing = '0', theatres = ''";
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    $sth->finish();
}

1;
