#!/usr/bin/perl

use CGI;

use lib '/tnmc';

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
    my $userId = $$news_ref{userId};
    my $value = $$news_ref{value};
    my $date = $$news_ref{date};

    news_edit($newsId,$userId,$date,$value);
}
    
footer();
db_disconnect();
