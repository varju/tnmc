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
use tnmc::cgi;

#############
### Main logic

&tnmc::template::header();

my $movieID = &tnmc::cgi::param('movieID');
&print_movie_edit_admin_form($movieID);

&tnmc::template::footer();

#
# subs
#

sub print_movie_edit_admin_form{
    my ($movieID) = @_;
    
    my %movie;
    my @cols = &tnmc::db::db_get_cols_list('Movies');
    &tnmc::movies::movie::get_movie($movieID, \%movie);
    
    print qq 
    {    <form action="movies/movie_edit_submit.cgi" method="post">
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

}
