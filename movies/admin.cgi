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

    #############
    ### Main logic

    &db_connect();
    &header();

    my (@movies, $movieID, %movie, %current_movie);

    if ($USERID)
    {     &show_heading ("administration");
      
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


        $current_movie{$current_movie} = "SELECTED";

        print qq 
                {       <form action="admin_submit.cgi" method="post">
                        <table>
        
                        <tr>
            <td><b>Movie</td>
                        <td><select name="movie_current_movie">
                <option value="0">NO CURRENT MOVIE
        };
    
            foreach $movieID (@movies)
            {       &get_movie($movieID, \%movie);
            print qq
            {    <option value="$movie{'movieID'}" $current_movie{$movieID} >$movie{'title'}
            }
            };

    
        print qq 
        {    </select>
                   </tr>
            
            <tr>
            <td><b>Cinema</td>
            <td><input type="text" name="movie_current_cinema" value="$current_cinema")></td>
            </tr>

            <tr>
            <td><b>Showtime</td>
            <td><input type="text" name="movie_current_showtime" value="$current_showtime"></td>
            </tr>

            <tr>
                        <td><b>Meeting Place</td>
                        <td><input type="text" name="movie_current_meeting_place" value="$current_meeting_place"></td>
                        </tr>

            <tr>
            <td><b>Meeting Time</td>
            <td><input type="text" name="movie_current_meeting_time" value="$current_meeting_time"></td>
            </tr>

            <tr>
            <td><b>Vote Blurb</td>
            <td><textarea cols="19" rows="5" wrap="virtual" name="movie_vote_blurb">$vote_blurb</textarea></td>
            </tr>

            <tr>
            <td><b>Winner Blurb</td>
            <td><textarea cols="19" rows="5" wrap="virtual" name="movie_winner_blurb">$winner_blurb</textarea></td>
            </tr>

            <tr>
            <td><b>Current NightID</td>
            <td><input type="text" name="movie_current_nightID" value="$current_nightID"></td>
            </tr>

            <tr>
            <td><b>Valid Theatres</td>
            <td><textarea cols="19" rows="6" wrap="virtual" name="movie_valid_theatres">$valid_theatres</textarea></td>
            </tr>

            <tr>
            <td><b>Other Theatres</td>
            <td><textarea cols="19" rows="6" wrap="virtual" name="movie_other_theatres">$other_theatres</textarea></td>
            </tr>


            </table>

            <p>    
            <input type="image" border=0 src="/template/submit.gif" alt="Submit Changes">
            </form>
        }; 

        ## List of Future Nights
        &show_heading ("future nights");
        my @NIGHTS;
        &list_nights(\@NIGHTS, "WHERE date >= NOW()", "");
        foreach my $nightID (@NIGHTS){
            my %night;
            &get_night ($nightID, \%night);
            print qq{
                <a href="night_edit_admin.cgi?nightID=$nightID">$night{date}</a>
                ($nightID)<br>
            };
        }
        
     
    }

    

    &footer();

