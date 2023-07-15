#!/usr/bin/perl

use strict;
use warnings;

use lib '/tnmc';

use tnmc::config;
use tnmc::security::auth;
use tnmc::cgi;
use tnmc::news::util;

#############
### Main logic

&tnmc::security::auth::authenticate();

my $newsid = &tnmc::cgi::param('newsId');

&tnmc::news::util::del_news_item($newsid);

print "Location: /news/\n\n";
