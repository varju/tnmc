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

my $newsid = $tnmc_cgi->param('newsId');

del_news_item($newsid);

db_disconnect();

print "Location: /news/\n\n";
