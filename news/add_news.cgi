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
    show_heading("add news entry");

    my %news;
    $news{newsId} = 0;
    $news{userId} = $USERID;
    $news{date} = 0;
    $news{value} = "";

    news_edit(\%news);
}
    
footer();
db_disconnect();
