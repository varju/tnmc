#!/usr/bin/perl

use lib '/tnmc';
use strict;

use tnmc::security::auth;
use tnmc::template;
use tnmc::cgi;
use tnmc::news::template;
use tnmc::news::util;

#############
### Main logic

&tnmc::template::header();

if ($USERID) {
    &tnmc::template::show_heading("edit news entry");
    
    my $newsId = &tnmc::cgi::param('newsId');

    my $news_ref = &tnmc::news::util::get_news_item($newsId);
    &tnmc::news::template::news_edit($news_ref);
}
    
&tnmc::template::footer();
