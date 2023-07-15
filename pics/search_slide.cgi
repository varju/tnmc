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
use tnmc::user;

use tnmc::pics::new;
use tnmc::pics::search;

#############
### Main logic

&tnmc::security::auth::authenticate();

my $nav     = &tnmc::pics::new::get_nav();
my $piclist = &tnmc::pics::search::search_get_piclist_from_nav($nav);

&tnmc::template::html_black::header();
&show_search_slide_header($nav, $piclist);

&tnmc::pics::new::show_slide($nav, $piclist);

&tnmc::template::html_black::footer();

#
# subs
#

sub show_search_slide_header {
    my ($nav, $piclist) = @_;

    my $listLimit = 20;
    my $index     = &tnmc::pics::new::array_get_index($piclist, $nav->{'picID'});
    my $listStart = int($index / $listLimit) * $listLimit;

    my %nav           = %$nav;
    my @ignore_fields = ('picID', 'scale', 'span', 'play_delay');
    foreach my $field (@ignore_fields) {
        delete $nav{$field};
    }
    $nav{'listStart'} = $listStart;
    $nav{'listLimit'} = $listLimit;
    my $nav_url    = &tnmc::pics::new::make_nav_url(\%nav);
    my $search_url = "pics/$nav->{_nav_select}_thumb.cgi?$nav_url";

    ## album navigation stuff
    print qq{
        <b>
        <a href="index.cgi">TNMC</a> &nbsp; -> &nbsp;
        <a href="pics/index.cgi">Pics</a> &nbsp; -> &nbsp;
        <a href="pics/search_index.cgi">Search</a> &nbsp; -> &nbsp;
        <a href="pics/$search_url">Results</a> &nbsp; -> &nbsp;
        Slideshow &nbsp;&nbsp;
        </b>
    };

}
