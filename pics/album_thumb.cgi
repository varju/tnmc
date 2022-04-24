#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::template;

use tnmc::pics::new;

#############
### Main logic

&tnmc::template::header();

my $nav     = &tnmc::pics::new::get_nav();
my $albumID = $nav->{'albumID'};
my $piclist = &tnmc::pics::new::album_get_piclist_from_nav($nav);

# show album info
&tnmc::pics::new::show_album_thumb_header($albumID, $nav);

# show thumbs
&tnmc::pics::new::show_thumbs($piclist, $nav);

&tnmc::template::footer();

#
# subs
#
