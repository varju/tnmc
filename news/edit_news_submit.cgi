#!/usr/bin/perl

use CGI;

use lib '/tnmc';
use strict;

use tnmc::config;
use tnmc::security::auth;
use tnmc::db;

use tnmc::news::util;

#############
### Main logic

db_connect();
&tnmc::security::auth::authenticate();

my %news;
$news{newsId} = $tnmc_cgi->param('newsId');
$news{userId} = $tnmc_cgi->param('userId');
$news{value} = $tnmc_cgi->param('value');
$news{date} = $tnmc_cgi->param('date');
$news{expires} = $tnmc_cgi->param('expires');

set_news_item(\%news);

db_disconnect();

print "Location: /news/\n\n";
