#!/usr/bin/perl

use lib '/tnmc';
use strict;

use tnmc::config;
use tnmc::security::auth;
use tnmc::cgi;
use tnmc::news::util;

#############
### Main logic

&tnmc::security::auth::authenticate();

my $newsid = &tnmc::cgi::param('newsId');

del_news_item($newsid);

print "Location: /news/\n\n";
