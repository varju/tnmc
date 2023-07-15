#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::template::html_black;

use tnmc::pics::new;

#############
### Main logic

&tnmc::security::auth::authenticate();

my $nav     = &tnmc::pics::new::get_nav();
my $piclist = &tnmc::pics::new::album_get_piclist_from_nav($nav);

&tnmc::template::html_black::header();
&tnmc::pics::new::show_album_slide_header($nav, $piclist);

&tnmc::pics::new::show_slide($nav, $piclist);

&tnmc::template::html_black::footer();

#
# subs
#
