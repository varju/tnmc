#!/usr/bin/perl

use tnmc;

db_connect();

$sth = $dbh_tnmc->do(q{
    CREATE TABLE Mail
        (Id INT NOT NULL AUTO_INCREMENT,
         UserId INT,
         Date TIMESTAMP,
         AddrTo BLOB,    # To is reserved in Mysql
         AddrFrom BLOB,  # From is reserved in Mysql
         ReplyTo BLOB,
         Subject BLOB,
         Body BLOB,
         Header BLOB,
         PRIMARY KEY (Id))
        });

db_disconnect();
