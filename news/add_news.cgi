#!/usr/bin/perl

use lib '/tnmc';
use strict;

use tnmc::security::auth;
use tnmc::template;

use tnmc::news::template;
use tnmc::news::util;

#############
### Main logic

&tnmc::template::header();

if ($USERID) {
    &tnmc::template::show_heading("add news entry");

    my %news;
    $news{newsId} = 0;
    $news{userId} = $USERID;
    $news{date} = 0;
    $news{expires} = 0;
    $news{value} = "";

    &tnmc::news::template::news_edit(\%news);
}
    
&tnmc::template::footer();
