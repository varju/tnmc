#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::db;
use tnmc::template;
use tnmc::movies::movie;

{
    #############
    ### Main logic

    &header();
    
    my %movie;    
    my $cgih = new CGI;
    my $movieID = $cgih->param('movieID');
    
    &db_connect();
    my @cols = &db_get_cols_list($dbh_tnmc, 'Movies');
    &get_movie($movieID, \%movie);
    &db_disconnect();
    
    print qq 
    {    <form action="movie_edit_submit.cgi" method="post">
        <table>
    };

    foreach my $key (@cols)
    {       
        print qq 
        {    
            <tr valign=top><td>$key</td>
            };
        
        if ($key eq 'description')
        {    print qq {<td><textarea cols="50" rows="4" wrap="virtual" name="$key">$movie{$key}</textarea></td>};
         }
        else
        {    print qq {<td><input type="text" name="$key" value="$movie{$key}"></td>};
         }
        
        print "</tr>";
    }

    print qq
    {    </table>
        <input type="submit" value="Submit">
        </form>
    }; 

    &footer();
}
