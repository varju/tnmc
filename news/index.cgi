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
    show_heading("news");

    my $news_ref = get_news();
    news_print($news_ref,0,1,1);
}
    
footer();
