#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::user;

use tnmc::pics::new;

use strict;


#############
### Main logic

&db_connect();
&tnmc::security::auth::authenticate();


my $nav = &get_nav;
my $piclist = &album_get_piclist_from_nav($nav);


&tnmc::template::html_black::header();
&show_album_slide_header($nav, $piclist);

&show_slide($nav, $piclist);

&tnmc::template::html_black::footer();
&db_disconnect();


#
# subs
#
