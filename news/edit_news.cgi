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

    my $newsid = $tnmc_cgi->param('newsid');

    my $news_ref = get_news_item($newsid);
    my $userid = $$news_ref{user};
    my $value = $$news_ref{value};
    my $date = $$news_ref{date};

    news_edit($newsid,$userid,$date,$value);
}
    
footer();
db_disconnect();
