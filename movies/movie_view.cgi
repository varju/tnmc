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

    #############
    ### Main logic

    &header();

    &show_heading("movie detail");

    my %movie;    
    my $cgih = new CGI;
    my $movieID = $cgih->param('movieID');
    
    &show_movie_extended($movieID);
    
    &footer("movieView");


##################################################################
sub show_movie
{
    my ($movieID, $junk) = @_;    
    my (@cols, $movie, $key, $mybcID);
    
    if ($movieID)
    { 
        &db_connect();
         @cols = &db_get_cols_list($dbh_tnmc, 'Movies');
            &get_movie($movieID, \%movie);
        &db_disconnect();
          
        print qq 
        {
            <table>
        };
    
        foreach $key (@cols)
            {       if ($key eq 'movieID')
            {      next;
            }
            if ($key eq 'mybcID')
            {    next;
            }

            print qq 
            {    
                <tr valign=top><td><B>$key</B></td>
                    <td>$movie{$key}</td>
                </tr>
            };
            }

        if ($movie{'mybcID'})
        {    $mybcID = $movie{'mybcID'};
            print qq 
            {    <tr><td><b><a href="
                javascript:window.open(
                    'http://www2.mybc.com/aroundtown/movies/playing/movies/$mybcID.html',
                        'ViewMYBC'); index.cgi">myBC Info</a>
            };
        }
        print qq
        {    </table>
            <input type="submit" value="Submit">
            </form>
        }; 
    }
}
    
##################################################################
sub show_movie_extended
{
    my ($movieID, $junk) = @_;    
    my (@cols, $movie, %movie, $key, $mybcID);
    
    if ($movieID)
    { 
         @cols = &db_get_cols_list($dbh_tnmc, 'Movies');
            &get_movie_extended($movieID, \%movie);

        print qq 
        {
            <table>
        };
    
        foreach $key (sort(keys(%movie))){
            next if ($key eq 'votesText');
            next if ($key eq 'movieID');
            next if ($key eq 'mybcID');

            print qq{    
                <tr valign=top><td><B>$key</B></td>
                    <td>$movie{$key}</td>
                </tr>
            };
            }

        if ($movie{'mybcID'})
        {    $mybcID = $movie{'mybcID'};
            print qq 
            {    <tr><td><b><a href="
                javascript:window.open(
                    'http://www2.mybc.com/aroundtown/movies/playing/movies/$mybcID.html',
                        'ViewMYBC'); index.cgi">myBC Info</a>
            };
        }
        print qq
        {
            </table>
        }; 
    }
}

