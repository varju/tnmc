#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/';
use tnmc;
require 'MOVIES.pl';

	#############
	### Main logic

	&db_connect();
	&header();

	&get_user($USERID, \%REAL_USER);

	if (  ($REAL_USER{groupAdmin})
	   && ($tnmc_cgi->param('effectiveUserID')) ){
		$effectiveUserID = $tnmc_cgi->param('effectiveUserID');
	}else{
		$effectiveUserID = $USERID;
	}
	&get_user($effectiveUserID, \%USER);

	&show_movieMenu();
	&show_movies();
	&show_add_movie_form();

	&footer();
	&db_disconnect();


##########################################################
sub show_movies
{
	if ($REAL_USER{groupAdmin}){

		print qq{	
			<table border="0" cellpading="0" cellspacing="0" width="100%"><tr valign="top">
			<td align="right">
				<form action="index.cgi" method="post">
				<font face="verdana" size="-1" color="888888">

				<font face="verdana" size="-1" color="888888"><b>
        	                modify votes for</b>
                	        <select name="effectiveUserID" onChange="form.submit();">
		};

		$sql = "SELECT userID, username FROM Personal ORDER BY username";
		$sth = $dbh_tnmc->prepare($sql);
		$sth->execute();

		while (@row = $sth->fetchrow_array()){
			$userID = $row[0];
			$username = $row[1];
			if ($userID == $effectiveUserID) { $sel = 'selected';}
			else			{	$sel = '';}
			print qq{
				<option value="$userID" $sel>$username
			}
		};
	
		print qq{ 
				</select>
				</td>
				</form>
			</tr></table>
		};
	}

	&show_heading ("Detailed Votes");

	##################################################################
	### Start of list

	print qq{
		<table cellpadding="0" cellspacing="0" border="0">
		<tr  bgcolor="ffffff">
			<td><b>Edit</b></td>
			<td align="center"><b>N &nbsp;&nbsp; ? &nbsp;&nbsp; Y</b></td>
			<td align="center">&nbsp;&nbsp;&nbsp;<b>!</b></td>
			<td align="center">&nbsp;&nbsp;&nbsp;<b>+</b></td>
			<td align="center">&nbsp;&nbsp;&nbsp;<b>-</b></td>
			<td>&nbsp;&nbsp;</td>
			<td><b>Title</b></td>
			<td>&nbsp;&nbsp;</td>
			<td><b>Type</b></td>
			<td>&nbsp;&nbsp;</td>
			<td><b>Votes</b></td>
			</tr>
		<tr>
			<td colspan="11" bgcolor="cccccc" align="right">
				<form action="update_votes.cgi" method="post">
				<input type="hidden" name="userID" value="$effectiveUserID">
				<font color="888888"><b>now showing </td></tr>
	};

	########################
	# show_movie_list( "WHERE (m.status = 'showing' OR m.status = 'just released')");
	show_movie_list( "WHERE (m.statusShowing AND NOT (m.statusSeen OR 0))");

	print qq{	<tr>
			<td colspan="11" bgcolor="cccccc" align="right">
			<font color="888888"><b>coming soon </td></tr>
	};

	########################
	# show_movie_list( "WHERE m.status = 'coming soon'");
	show_movie_list( "WHERE (m.statusNew AND NOT (m.statusShowing OR 0))");


	print qq{\n	</table><p>\n};


	### End of list
	##################################################################


	########################
	### Do the Favorite Movie Stuff

	print qq{
		<font face="verdana">
		<b>Favorite Movie:</b><br>
		<select name="favoriteMovie">
		<option value="0">none
		<option value="0">
	};

	$sql = "SELECT movieID
	         FROM MovieVotes
	        WHERE userID = '$effectiveUserID' AND type = '2'";
	$sth = $dbh_tnmc->prepare($sql);
	$sth->execute;
	($favoriteMovie) = $sth->fetchrow_array();

	$sql = "SELECT movieID, title
	         FROM Movies
	        WHERE statusShowing = '1' AND statusSeen != '1'
	        ORDER BY title";

	$sth = $dbh_tnmc->prepare($sql);
	$sth->execute;

	while (@row = $sth->fetchrow_array()){
	        if ($favoriteMovie == $row[0]){         $faveSel = 'selected';}
	        else{                                   $faveSel = '';}
	        print qq{               <option value="$row[0]" $faveSel>$row[1]\n};
	}

        $sth->finish;

	print qq{
		</select><br>
		</font>
	};

	########################
	### Warn if modifying another user's votes.

	if ($effectiveUserID != $USERID){
		$useridNotice = qq{
			<font face="arial" size="+1" color="086DA5"><i><b>for $USER{username}</b></i></font>
		};
	}

	########################
	### Show the Update Votes buton.

	print qq{
		<input type="image" border="0" src="/template/update_votes_submit.gif" alt="Update Votes">$useridNotice
		</form>
	};
}



##########################################################
sub show_movie_list{

	($whereClause, $junk) = @_;

	$sql = "SELECT m.movieID, m.title, m.type, m.rating, m.statusShowing, m.statusNew,
		       p.username, v.type, p.movieAttendance
                 FROM           Movies as m 
                      LEFT JOIN MovieVotes as v USING (movieID)
                      LEFT JOIN Personal as p USING (userID)
		$whereClause
		ORDER BY m.title ASC, p.username ASC";

	$sth = $dbh_tnmc->prepare($sql);
	$sth->execute();

	# Here's what this loop tries to do:
	#
	# start of with an entry in @row, and movieID = 0.
	# while (there's an entry to process) {
	# 	save the current entry into movie variables,
	#	get the next row,
	#		if the movie id is the same as the current row, then increment some counters, andget the next row again
	#	print out the movie entry to the screen
	# the end.
	#

	@row = $sth->fetchrow_array();
	$movieID = 0;

	while ( $row[0] ){

		# set up the variables for this movie...
		# here's how the data comes in:
		#
		#   0          1        2       3         4                5            6           7       8
		# m.movieID, m.title, m.type, m.rating, m.statusShowing, m.statusNew, p.username, v.type, p.movieAttendance

		$movieID = $row[0];
		$title = $row[1];
		$type = $row[2];
		$rating = $row[3];
		$statusShowing = $row[4];
		$statusNew = $row[5];
		$votes = '';
		$votesFor = '';
		$votesForFave = '';
		$votesAgainst = '';

		# find out who voted for the movie...
		while ($row[0] == $movieID){
			$Vperson = $row[6];
			$Vtype = $row[7];
			$Vstatus = $row[8];
			if (!$Vstatus){
				if ($Vtype == 1){
					$votes .= "<font color='888888'>$Vperson</font> ";
					$votesAgainst ++;
				}
				if ($Vtype == 2){
					$votes .= "<font color='888888'><b>$Vperson</b></font> ";
					$votesAgainst += 2;
				}
			}
			elsif ($Vtype == 2){
				$votes .= "<b>$Vperson</b> ";
				$votesFor ++;
				$votesForFave ++;
			}
			elsif ($Vtype == 1){
				$votes .= "$Vperson ";
				$votesFor ++;
			}
			elsif ($Vtype == -1){
				$votes .= "<font color='ff2222'>$Vperson</font> ";
				$votesAgainst ++;
			}

			@row = $sth->fetchrow_array();
		}


                %vote_status_word = ();
                $vote = &get_vote($movieID, $effectiveUserID);
                $vote_status_word{$vote} = "CHECKED";
                
		print qq{
			<tr valign="top">
				<td><a href="movie_edit.cgi?movieID=$movieID"><font color="cccccc">$movieID</a></td>
				<td valign="top" nowrap><input type="radio" name="v$movieID" value="-1" $vote_status_word{'-1'}><input type="radio" name="v$movieID" value="0" $vote_status_word{'0'}><input type="radio" name="v$movieID" value="1" $vote_status_word{'1'} $vote_status_word{'2'}></td>
				<td align="right">$votesForFave</td>
				<td align="right">$votesFor</td>
				<td align="right">$votesAgainst</td>
				<td></td>
				<td valign="top">
		};
		if ($statusShowing && $statusNew) { print qq{					<b>}; }
		print qq{
					<a href="
					javascript:window.open(
						'movie_view.cgi?movieID=$movieID',
						'ViewMovie',
						'resizable,height=350,width=450');
						index.cgi
					">$title</a></td>
				<td></td>
				<td>$type</td>
				<td></td>
				<td>$votes</td>

			</tr>
		};
	}
	$sth->finish();


}



##########################################################
sub show_add_movie_form
{

	print qq{
                <form action="movie_edit_submit.cgi" method="post">
                <input type="hidden" name="movieID" value="0">
	};
	&show_heading ("add a new movie");
	
        print qq{
                <table border="0">
                <tr valign=top>
                        <td colspan="4"><b>Title</b><br>
                
                        <input type="text" size="41" name="title" value=""></td>
                </tr>
        
                <tr valign=top>
                        <td><b>Type</b><br>
                        <input type="text" size="12" name="type" value=""></td>

                        <td><b>Rating</b><br>
                        <input type="text" size="3" name="rating" value=""></td>

                        <td><b>MyBC ID</b><br>
                        <input type="text" size="6" name="mybcID" value=""></td>

                        <td><b>Status</b><br><b>
			<input type="checkbox" name="statusNew" value="1" checked>New
			<input type="checkbox" name="statusShowing" value="1">Showing
                        </td>  


                </tr> 
        
                <tr valign=top>
                        <td colspan="4"><b>Description</b><br>
                        <textarea cols="40" rows="4" wrap="virtual" name="description"></textarea></td>
                </tr>
        
                       
                </table>
		<input type="image" border=0 src="/template/submit.gif" alt="Submit Changes">
                </form> 
        };                      
                                

}


##########################################################
#### The end.
##########################################################

