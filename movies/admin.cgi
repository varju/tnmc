#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
#	Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/';
use tnmc;
require 'MOVIES.pl';

	#############
	### Main logic

	&db_connect();
	&header();

	%user;	
	$cgih = new CGI;

	my (@movies, $movieID, %movie);
	
	if ($USERID)
	{ 	&show_heading ("administration");

		&get_user($userID, \%user);
	  
       		&list_movies(\@movies, "WHERE movieID = 68 OR statusShowing AND NOT
(statusSeen OR 0)", 'ORDER BY title');

		$current_movie =  &get_general_config("movie_current_movie");
		$current_cinema = &get_general_config("movie_current_cinema"); 
		$current_showtime = &get_general_config("movie_current_showtime");
		$current_meeting_place = &get_general_config("movie_current_meeting_place");
		$current_meeting_time = &get_general_config("movie_current_meeting_time");

		$vote_blurb = &get_general_config("movie_vote_blurb");
		$winner_blurb = &get_general_config("movie_winner_blurb");

		$valid_theatres = &get_general_config("movie_valid_theatres");
		$current_nightID = &get_general_config("movie_current_nightID");


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
			{	<option value="$movie{'movieID'}" $current_movie{$movieID} >$movie{'title'}
			}
        	};

	
		print qq 
		{	</select>
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
			<td><b>Valid Thetres</td>
			<td><textarea cols="19" rows="6" wrap="virtual" name="movie_valid_theatres">$valid_theatres</textarea></td>
			</tr>

			</table>

			<p>	
			<input type="image" border=0 src="/template/submit.gif" alt="Submit Changes">
			</form>
		}; 
	}
	

	&footer();

