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
my $tnmc_cgi = &tnmc::cgi::get_cgih();

my %news;
$news{newsId} = $tnmc_cgi->param('newsId');
$news{userId} = $tnmc_cgi->param('userId');
$news{value} = $tnmc_cgi->param('value');
$news{date} = $tnmc_cgi->param('date');
$news{expires} = $tnmc_cgi->param('expires');

set_news_item(\%news);

print "Location: /news/\n\n";
