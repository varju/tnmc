#!/usr/bin/perl

use CGI;

use lib '/tnmc';
use strict;

use tnmc::config;
use tnmc::cookie;
use tnmc::db;

use tnmc::news::util;

#############
### Main logic

db_connect();
cookie_get();

my $newsId = $tnmc_cgi->param('newsId');
my $userId = $tnmc_cgi->param('userId');
my $value = $tnmc_cgi->param('value');
my $date = $tnmc_cgi->param('date');

set_news_item($newsId,$userId,$value,$date);

db_disconnect();

print "Location: $tnmc_url/news/\n\n";
