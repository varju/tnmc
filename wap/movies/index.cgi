#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::template::wml;
use tnmc::db;
use tnmc::movies::movie;

#############
### Main logic

&tnmc::template::wml::wml_header();

## movie menu

my $movie_menu = qq{
        <p>
        <a href="#current">Current</a><br/>
        <br/>
        <a href="#list">List</a><br/>
        </p>
        };

# &tnmc::template::wml::show_card("menu", "TNMC Movies", $movie_menu);

## movie listing

my $movies = &tnmc::movies::movie::list_active_movie_titles();

my $list_wml = '';
foreach my $title (sort keys %$movies) {
    $list_wml .= "<a href=\"movie_view.cgi?movieID=$movies->{$title}\">$title</a><br/>\n";
}

my $movie_list = qq{
        <p>
        $list_wml
        </p>
        };
&tnmc::template::wml::show_card("list", "TNMC Movie list", $movie_list);

&tnmc::template::wml::wml_footer();
