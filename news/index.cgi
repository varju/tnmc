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
    &tnmc::template::show_heading("news");

    my $news_ref = &tnmc::news::util::get_news();
    &tnmc::news::template::news_print($news_ref,0,1,1);
}
    
&tnmc::template::footer();
