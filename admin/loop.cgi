#!/usr/bin/perl

use DBI;
use CGI;

use lib '/usr/local/apache/tnmc/';
use tnmc;


        &db_connect();

for ($i = 1; $i <= 60; $i++){
	print "$ARGV[0] $i\n";
	sleep(1);
}
