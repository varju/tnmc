#!/usr/bin/perl

use tnmc;

db_connect();

$dbh_tnmc->do(q{
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

$dbh_tnmc->do(q{
    CREATE TABLE MailPrefs
        (UserId INT,
         Pref VARCHAR(20),
         Value VARCHAR(20))
        });

$dbh_tnmc->do(q{
    ALTER TABLE Mail
        ADD COLUMN Sent INT
        });

$dbh_tnmc->do(q{
    ALTER TABLE Mail
        ADD COLUMN Folder INT
        });

$dbh_tnmc->do(q{
    CREATE TABLE MailFolder
        (FolderId INT NOT NULL AUTO_INCREMENT,
         Name BLOB,
         PRIMARY KEY (FolderId))
        });

db_disconnect();
