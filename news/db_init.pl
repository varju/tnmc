#!/usr/bin/perl

use warnings;

use tnmc;
use tnmc::db;

my $dbh = &tnmc::db::db_connect();

$dbh->do(
    q{
    CREATE TABLE News
        (newsID INT NOT NULL AUTO_INCREMENT,
         userID INT,
         value BLOB,
         date TIMESTAMP,
         PRIMARY KEY (newsID))
        }
);

$dbh->do(
    q{
    ALTER TABLE News
        ADD COLUMN expires TIMESTAMP AFTER date
        }
);
