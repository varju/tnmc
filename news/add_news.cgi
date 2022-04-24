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

    my ($sec, $min, $hour, $day, $mon, $yr) = localtime();
    $mon++;
    $yr += 1900;

    my %news;
    $news{newsId}  = 0;
    $news{userId}  = $USERID;
    $news{date}    = sprintf("%04d%02d%02d%02d%02d%02d", $yr, $mon, $day, $hour, $min, $sec);
    $news{expires} = &tnmc::news::util::news_default_expiry();
    $news{value}   = "";

    &tnmc::news::template::news_edit(\%news);
}

&tnmc::template::footer();
