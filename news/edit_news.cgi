#!/usr/bin/perl

use CGI;

use lib '/tnmc';
use strict;

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::cgi;
use tnmc::news::template;
use tnmc::news::util;

#############
### Main logic

db_connect();
header();

if ($USERID) {
    show_heading("edit news entry");
    
    my $tnmc_cgi = &tnmc::cgi::get_cgih();

    my $newsId = $tnmc_cgi->param('newsId');

    my $news_ref = get_news_item($newsId);
    news_edit($news_ref);
}
    
footer();
db_disconnect();
