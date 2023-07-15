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

use CGI;
my $cgih = new CGI;

&db_connect();

&tnmc::template::wml::wml_header();

my $movieID = $cgih->param('movieID');

my %movie;
&tnmc::movies::movie::get_movie_extended($movieID, \%movie);

my $fido_url = $movie{title};
$fido_url =~ s/ /_/g;
$fido_url = "http://wap.cinemaclock.com/cgi-bin/fido/nokia/wapcm.cgi?w=bri-Vancouver-e-" . $fido_url;

my $movie_card = qq{
    <p>
    Title: $movie{'title'}<br/>
    Votes: $movie{'order'} ($movie{votesForTotal}+ $movie{votesAgainst}-) <br/>
    <br/>
    Votes: $movie{'votesText'}<br/>
    <a href="$fido_url">iFido info</a>
    </p>
};
&tnmc::template::wml::show_card("movie_$movieID", $movie{'title'}, $movie_card);

&tnmc::template::wml::wml_footer();

&db_disconnect();
