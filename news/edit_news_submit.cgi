#!/usr/bin/perl

use CGI;

use lib '/tnmc';

use tnmc::cookie;
use tnmc::db;

use tnmc::news::util;

#############
### Main logic

db_connect();
cookie_get();

my $newsid = $tnmc_cgi->param('newsid');
my $userid = $tnmc_cgi->param('userid');
my $value = $tnmc_cgi->param('value');
my $date = $tnmc_cgi->param('date');

set_news_item($newsid,$userid,$value,$date);

db_disconnect();

print "Location: $tnmc_url/news/\n\n";
