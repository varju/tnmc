#!/usr/bin/perl

use lib '/tnmc';
use strict;

use tnmc::security::auth;
use tnmc::template;

use tnmc::news::template;
use tnmc::news::util;

#############
### Main logic

header();

if ($USERID) {
    show_heading("add news entry");

    my %news;
    $news{newsId} = 0;
    $news{userId} = $USERID;
    $news{date} = 0;
    $news{expires} = 0;
    $news{value} = "";

    news_edit(\%news);
}
    
footer();
