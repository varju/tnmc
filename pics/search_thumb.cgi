#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::db;
use tnmc::template;
use tnmc::pics::new;
use tnmc::pics::search;

#############
### Main logic

&db_connect();
&header();

my $nav = &get_nav;
my $albumID = $nav->{'albumID'};
my $piclist = &search_get_piclist_from_nav($nav);

# show album info
&show_search_thumb_header($nav, $piclist);

# show thumbs
&show_thumbs($piclist, $nav);

&footer();
&db_disconnect();

#
# subs
#


sub show_search_thumb_header{
    my ($nav, $piclist) = @_;
    
    &show_heading("search - $nav->{'mode'}");
    my $count = scalar(@$piclist);
    
    print qq{
        <p>
        <b>$count</b> Pictures found<br>
        <p>
    };
    
}
