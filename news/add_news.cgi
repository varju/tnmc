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
    show_heading("add news entry");

    news_edit(0,$USERID,0,"");
}
    
footer();
db_disconnect();
