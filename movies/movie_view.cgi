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
        if ($movie{'filmcanID'})
        {    
	    my $filmcanID = $movie{'filmcanID'};
            print qq 
            {    <tr><td><b><a href="http://vancouver.film-can.com/cgi-bin/main/mview.cgi?FID=$filmcanID" target="filmcan">FilmCan Info</a>
            };
        }
        if ($movie{'cinemaclockID'} && $movie{'cinemaclockPage'})
        {    
	    my $cinemaclockID = $movie{'cinemaclockID'};
	    $cinemaclockID =~ s/\.3d$//;
	    my $cinemaclockPage = $movie{'cinemaclockPage'};
            print qq 
            {    <tr><td><b><a href="http://www.cinemaclock.com/aw/crva.aw/bri/Vancouver/e/$cinemaclockID/$cinemaclockPage" target="filmcan">Cinemaclock Info</a>
            };
        }
        print qq
        {
            </table>
        }; 
    }
}
