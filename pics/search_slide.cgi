#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::template::html_black;
use tnmc::user;

use tnmc::pics::new;
use tnmc::pics::search;

use strict;


#############
### Main logic

&db_connect();
&tnmc::security::auth::authenticate();


my $nav = &get_nav;
my $piclist = &search_get_piclist_from_nav($nav);


&tnmc::template::html_black::header();
&show_search_slide_header($nav, $piclist);

&show_slide($nav, $piclist);

&tnmc::template::html_black::footer();
&db_disconnect();


#
# subs
#

sub show_search_slide_header{
    my ($nav, $piclist) = @_;
    
    my $listLimit = 20;
    my $index = &array_get_index($piclist, $nav->{'picID'});
    my $listStart = int($index / $listLimit) * $listLimit;
    
    my %nav = %$nav;
    my @ignore_fields = ('picID', 'scale', 'span', 'play_delay');
    foreach my $field (@ignore_fields){
        delete $nav{$field};
    }
    $nav{'listStart'} = $listStart;
    $nav{'listLimit'} = $listLimit;
    my $nav_url = &make_nav_url(\%nav);
    my $search_url = "$nav->{_nav_select}_thumb.cgi?$nav_url";
    
    ## album navigation stuff
    print qq{
        <b>
        <a href="/">TNMC</a> &nbsp; -> &nbsp;
        <a href="index.cgi">Pics</a> &nbsp; -> &nbsp;
        <a href="search_index.cgi">Search</a> &nbsp; -> &nbsp;
        <a href="$search_url">Results</a> &nbsp; -> &nbsp;
        Slideshow &nbsp;&nbsp;
        </b>
    };

}
