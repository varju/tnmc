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
&header();

&show_heading("movie detail");
my $cgih = &tnmc::cgi::get_cgih();

my $movieID = $cgih->param('movieID');

&show_movie_extended($movieID);

&footer("movieView");

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
        &get_movie_extended($movieID, \%movie);
        
        print qq 
        {
            <table>
        };
        
        foreach $key (sort(keys(%movie))){
            next if ($key eq 'votesText');
            next if ($key eq 'movieID');
            next if ($key eq 'mybcID');
            next if ($key eq 'imdbID');
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
            {    <tr><td><b><a href="http://www2.mybc.com/movies/movies/$mybcID.html" target="mybc">myBC Info</a>
            };
        }
        if ($movie{'imdbID'})
        {    $imdbID = $movie{'imdbID'};
            print qq 
            {    <tr><td><b><a href="http://www.imdb.com/Title?$imdbID" target="imdb">IMDB Info</a>
            };
        }
        print qq
        {
            </table>
        }; 
    }
}
