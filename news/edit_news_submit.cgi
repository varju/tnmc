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

my %news;
$news{newsId} = &tnmc::cgi::param('newsId');
$news{userId} = &tnmc::cgi::param('userId');
$news{value} = &tnmc::cgi::param('value');
$news{date} = &tnmc::cgi::param('date');
$news{expires} = &tnmc::cgi::param('expires');

&tnmc::news::util::set_news_item(\%news);

print "Location: /news/\n\n";
