#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca 
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::cookie;
use tnmc::db;
use tnmc::template;
use tnmc::movies::movie;
use tnmc::movies::show;
use tnmc::movies::vote;

    #############
    ### Main logic
    
    &header();
    &db_connect();

    &show_showing_movie_list();

    &db_disconnect();
    &footer();

##########################################################
#### sub procedures.
##########################################################

#########################################
sub show_showing_movie_list{
    my (@movies, %movie, $movieID, $key);

    &list_movies(\@movies, "WHERE statusShowing = '1'", 'ORDER BY title');

    &show_heading("All Movies that are Currently Showing in Vancouver");
    print qq{
        <font color="0000ff">Blue means we've seen it</font><br>
        <b>Bold means you voted for it</b><br>
        <br>
                <table cellspacing="0" cellpadding="1" border="0" width="100%">
    };

    my $year = '';
        foreach $movieID (@movies){
        my %movie = ();
                &get_movie_extended($movieID, \%movie);
        
        my $my_vote = '';
        if (&get_vote($movieID, $USERID) >= 1){
            $my_vote = "<b>";
        }
        my $seen_colour = '';
        if ($movie{statusSeen}){
            $seen_colour = '<font color="0000ff">';
        }
        
        print qq{
            <tr>
                <td nowrap>$movie{rank}</td>
                <td nowrap>$my_vote$seen_colour$movie{title}</td>
                <td nowrap>&nbsp;&nbsp;$movie{theatres}</td>
                <td nowrap>&nbsp;<a href="
                    javascript:window.open(
                    'movie_view.cgi?movieID=$movieID',
                    'ViewMovie',
                    'resizable,height=350,width=450');
                    index.cgi
                    ">v</a>
            </tr>
        };
        }

    print qq{
                </table>
        };
}


##########################################################
#### The end.
##########################################################


