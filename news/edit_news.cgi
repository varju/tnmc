#!/usr/bin/perl

use CGI;

use lib '/tnmc';
use strict;

use tnmc::cookie;
use tnmc::db;
use tnmc::template;

use tnmc::news::template;
use tnmc::news::util;

#############
### Main logic

db_connect();
header();

if ($USERID) {
    show_heading("edit news entry");

    my $newsId = $tnmc_cgi->param('newsId');

    my $news_ref = get_news_item($newsId);
    news_edit($news_ref);
}
    
footer();
db_disconnect();
