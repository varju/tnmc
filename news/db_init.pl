#!/usr/bin/perl

use tnmc;

db_connect();

$dbh_tnmc->do(q{
    CREATE TABLE News
        (newsID INT NOT NULL AUTO_INCREMENT,
         userID INT,
         value BLOB,
         date TIMESTAMP,
         PRIMARY KEY (newsID))
        });

$dbh_tnmc->do(q{
    ALTER TABLE News
        ADD COLUMN expires TIMESTAMP AFTER date
        });

db_disconnect();
