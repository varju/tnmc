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
    show_heading("news");

    my $news_ref = get_news();
    news_print($news_ref,0,1);
}
    
footer();
db_disconnect();
