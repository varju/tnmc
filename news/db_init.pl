#!/usr/bin/perl

use tnmc;

db_connect();

$sth = $dbh_tnmc->do(q{
    CREATE TABLE News
        (newsID INT NOT NULL AUTO_INCREMENT,
         userID INT,
         value BLOB,
         date TIMESTAMP,
         PRIMARY KEY (newsID))
        });

db_disconnect();
