#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::cookie;
use tnmc::db;
use tnmc::general_config;
use tnmc::template;
use tnmc::movies::movie;
use tnmc::movies::night;
use tnmc::movies::show;

{
    #############
    ### Main logic
    
    &db_connect();
    &header();
    
    use CGI;
    my $cgih = new CGI;
    
    my $nightID = $cgih->param('nightID');
    
    &show_night_edit_form($nightID);
    
    &footer();
    db_disconnect();

}

sub show_night_edit_form{
    my ($nightID) = @_;
    
    my %night;
    &get_night($nightID, \%night);
    
    my (@movies, $movieID, %movie, %current_movie);
    
    &show_heading("edit night: $nightID");
        
    &list_movies(\@movies, "WHERE statusShowing AND NOT (statusSeen OR 0)", 'ORDER BY title');
    
    my $current_movie =  &get_general_config("movie_current_movie");
    my $current_cinema = &get_general_config("movie_current_cinema"); 
    my $current_showtime = &get_general_config("movie_current_showtime");
    my $current_meeting_place = &get_general_config("movie_current_meeting_place");
    my $current_meeting_time = &get_general_config("movie_current_meeting_time");
    
    my $vote_blurb = &get_general_config("movie_vote_blurb");
    my $winner_blurb = &get_general_config("movie_winner_blurb");
    
    my $valid_theatres = &get_general_config("movie_valid_theatres");
    my $other_theatres = &get_general_config("movie_other_theatres");
    my $current_nightID = &get_general_config("movie_current_nightID");


    $current_movie{$night{'movieID'}} = "SELECTED";
    
    print qq{
        <form action="night_edit_submit.cgi" method="post">
        <input type="hidden" name="nightID" value="$nightID">
        <table>
        
            <tr>
            <td><b>Movie</td>
            <td><select name="movieID">
                <option value="0">NO CURRENT MOVIE
    };
    
    foreach $movieID (@movies){
        &get_movie($movieID, \%movie);
        print qq{
                <option value="$movie{'movieID'}" $current_movie{$movieID} >$movie{'title'}
        };
    }
    
    
    print qq{
                </select>
            </tr>
            
            <tr>
            <td><b>date</td>
            <td><input type="text" name="date" value="$night{'date'}")></td>
            </tr>
                
            <tr>
            <td><b>Cinema</td>
            <td><input type="text" name="theatre" value="$night{'theatre'}")></td>
            </tr>
            
            <tr>
            <td><b>Showtime</td>
            <td><input type="text" name="showtime" value="$night{'showtime'}"></td>
            </tr>
            
            <tr>
            <td><b>Meeting Place</td>
            <td><input type="text" name="meetingPlace" value="$night{'meetingPlace'}"></td>
            </tr>
            
            <tr>
            <td><b>Meeting Time</td>
            <td><input type="text" name="meetingTime" value="$night{'meetingTime'}"></td>
            </tr>
            
            <tr>
            <td><b>Vote Blurb</td>
            <td><textarea cols="19" rows="5" wrap="virtual" name="voteBlurb">$night{'voteBlurb'}</textarea></td>
            </tr>

            <tr>
            <td><b>Winner Blurb</td>
            <td><textarea cols="19" rows="5" wrap="virtual" name="winnerBlurb">$night{'winnerBlurb'}</textarea></td>
            </tr>
            
            </table>

            <p>    
            <input type="image" border=0 src="/template/submit.gif" alt="Submit Changes">
            </form>
    }; 

}



