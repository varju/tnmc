#!/usr/bin/perl

use tnmc;

db_connect();

$sth = $dbh_tnmc->do(q{
    CREATE TABLE Mail
        (Id INT NOT NULL AUTO_INCREMENT,
         UserId INT,
         AddrTo BLOB,    # To is reserved in Mysql
         AddrFrom BLOB,  # From is reserved in Mysql
         Date BLOB,
         ReplyTo BLOB,
         Body BLOB,
         Header BLOB,
         PRIMARY KEY (Id))
        });

db_disconnect();
