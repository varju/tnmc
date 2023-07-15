#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use warnings;

use lib '/tnmc';

use tnmc::template;
use tnmc::pics::new;
use tnmc::pics::search;

#############
### Main logic

&tnmc::template::header();

my $nav     = &tnmc::pics::new::get_nav();
my $albumID = $nav->{'albumID'};
my $piclist = &tnmc::pics::search::search_get_piclist_from_nav($nav);

# show album info
&show_search_thumb_header($nav, $piclist);

# show thumbs
&tnmc::pics::new::show_thumbs($piclist, $nav);

&tnmc::template::footer();

#
# subs
#

sub show_search_thumb_header {
    my ($nav, $piclist) = @_;

    &tnmc::template::show_heading("search - $nav->{'mode'}");
    my $count = scalar(@$piclist);

    print qq{
        <p>
        <b>$count</b> Pictures found<br>
        <p>
    };

}
