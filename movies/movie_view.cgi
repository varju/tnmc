#!/usr/bin/perl

##################################################################
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::template;
use tnmc::db;
use tnmc::movies::movie;
use tnmc::cgi;
use tnmc::util::date;


#############
### Main logic
&tnmc::template::header();

&tnmc::template::show_heading("movie detail");

my $movieID = &tnmc::cgi::param('movieID');

&show_movie_extended($movieID);

&tnmc::template::footer("movieView");

#
# subs
#

##################################################################
sub show_movie_extended
{
    my ($movieID, $junk) = @_;    
    my (@cols, $movie, %movie, $key, $mybcID, $imdbID);
    
    if ($movieID)
    { 
        &tnmc::movies::movie::get_movie_extended2($movieID, \%movie);
        
        print qq 
        {
            <table>
        };
        
        foreach $key (sort(keys(%movie))){
            next if ($key eq 'votesText');
            next if ($key eq 'movieID');
            next if ($key eq 'mybcID');
            next if ($key eq 'imdbID');
            next if ($key eq 'filmcanID');
            next if ($key eq 'cinemaclockID');
            next if ($key eq 'cinemaclockPage');
            next if ($key eq 'googleID');
            next if ($key eq 'cineplexID');
            next if ($key eq 'theatres');
            next if ($key eq 'theatres_string');
            
            print qq{    
                <tr valign=top><td><B>$key</B></td>
                    <td>$movie{$key}</td>
                </tr>
            };
            }
        
        if ($movie{'mybcID'})
        {    $mybcID = $movie{'mybcID'};
            print qq 
            {    <tr><td><b><a href="http://www.mytelus.com/movies/mdetails.do?movieID=$mybcID" target="mybc">myBC Info</a>
            };
        }
        if ($movie{'imdbID'})
        {    $imdbID = $movie{'imdbID'};
            print qq 
            {    <tr><td><b><a href="http://www.imdb.com/Title?$imdbID" target="imdb">IMDB Info</a>
            };
        }
        if ($movie{'cinemaclockID'} && $movie{'cinemaclockPage'})
        {    
	    my $cinemaclockID = $movie{'cinemaclockID'};
	    $cinemaclockID =~ s/\.3d$//;
	    my $cinemaclockPage = $movie{'cinemaclockPage'};
            print qq 
            {    <tr><td><b><a href="http://www.cinemaclock.com/aw/crva.aw/bri/Vancouver/e/$cinemaclockID/$cinemaclockPage" target="cinemaclock">Cinemaclock Info</a>
            };
        }
        if ($movie{'googleID'})
        {
	    my $googleID = $movie{'googleID'};
            print qq 
            {    <tr><td><b><a href="http://www.google.com/movies?mid=$googleID" target="google">Google info</a>
            };
        }
        if ($movie{'cineplexID'})
        {
        my $cineplexID = $movie{'cineplexID'};
        my $next_tuesday = &tnmc::util::date::get_next_tuesday();
            print qq 
            {    <tr><td><b><a href="http://www.cineplex.com/Movie/$cineplexID" target="cineplex">Cineplex info</a></b></td></tr>
                 <tr><td><b><a href="http://www.cineplex.com/Showtimes/$cineplexID/vancouver-bc?Date=$next_tuesday" target="cineplex_show">Cineplex showtimes</a></b></td></tr>
            };
        }
        print qq
        {
            </table>
        }; 
    }
}
