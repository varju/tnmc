#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::db;
use tnmc::template;
use tnmc::pics::new;

#############
### Main logic

&db_connect();
&header();

my $nav = &get_nav;
my $albumID = $nav->{'albumID'};
my $piclist = &album_get_piclist_from_nav($nav);

# show album info
&show_album_thumb_header($albumID, $nav);

# show thumbs
&show_thumbs($piclist, $nav);

&footer();
&db_disconnect();

#
# subs
#

