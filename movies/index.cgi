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
#	&show_add_movie_form();



	#############
	### Main logic

	&get_user($USERID, \%REAL_USER);
#
#	if (  ($REAL_USER{groupAdmin})
#	   && ($tnmc_cgi->param('effectiveUserID')) ){
#		$effectiveUserID = $tnmc_cgi->param('effectiveUserID');
#	}else{
#		$effectiveUserID = $USERID;
#	}
#	&get_user($effectiveUserID, \%USER);

#	&show_movieMenu();
#	&show_movies();
#	&show_add_movie_form();




#	$current_movie =  &get_general_config("movie_current_movie");
#	if ($current_movie){
#	        &show_current_movie();
#        }
#	else{
#		if ($USERID){
#			&show_heading('Attendance - When can you go to the movies?');
#			&list_my_attendance($USERID);
#		};
#		&show_movies();
#	}


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

	&list_my_attendance($effectiveUserID);
	&show_heading ("Detailed Votes");

	##################################################################
	### Start of list

	print qq{
		<table cellpadding="0" cellspacing="0" border="0">
		<tr  bgcolor="ffffff">
			<td><b>Edit</b></td>
			<td align="center"><b>N &nbsp;&nbsp; ? &nbsp;&nbsp; Y</b></td>
			<td align="right">&nbsp;&nbsp;<b>!</b></td>
			<td align="right">&nbsp;&nbsp;<b>+</b></td>
			<td align="right">&nbsp;&nbsp;<b>-</b></td>
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
	show_movie_list( "WHERE (statusShowing AND NOT (statusSeen OR 0))");

	print qq{	<tr>
			<td colspan="11" bgcolor="cccccc" align="right">
			<font color="888888"><b>coming soon </td></tr>
	};

	########################
	# show_movie_list( "WHERE m.status = 'coming soon'");
	show_movie_list( "WHERE (statusNew AND NOT (statusShowing OR 0))");


	print qq{\n	</table><p>\n};


	### End of list
	##################################################################


	########################
	### Do the Favorite Movie Stuff

	print qq{
		<font face="verdana">
		<b>Favorite Movie:</b><br>
	};
	&show_favorite_movie_select($effectiveUserID);
	print qq{
		<br></font>
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

	my (@movies, $anon, $movieID, $movieInfo);
	my ($boldNew, %vote_status_word);

	&list_movies(\@list, $whereClause, 'ORDER BY title');
	foreach $movieID (@list){
		$anon = {}; 	### create an anonymous hash.
		&get_movie_extended($movieID, $anon);
		$movieInfo{$movieID} = $anon;
	}
	
#        @list = sort  {       $movieInfo{$b}->{order}
#                        <=>     $movieInfo{$a}->{order}}
#                        @list ;

	foreach $movieID (@list){

                %vote_status_word = ();
                $vote = &get_vote($movieID, $effectiveUserID);
                $vote_status_word{$vote} = "CHECKED";
                
		$votesFor = $movieInfo{$movieID}->{votesFor}
			  + $movieInfo{$movieID}->{votesFave}
			  + $movieInfo{$movieID}->{votesBday};
		print qq{
			<tr valign="top">
				<td><a href="movie_edit.cgi?movieID=$movieID"><font color="cccccc">$movieID</a></td>
				<td valign="top" nowrap><input type="radio" name="v$movieID" value="-1" $vote_status_word{'-1'}><input type="radio" name="v$movieID" value="0" $vote_status_word{'0'}><input type="radio" name="v$movieID" value="1" $vote_status_word{'1'} $vote_status_word{'2'}></td>
				<td align="right">$movieInfo{$movieID}->{rank}</td>
				<td align="right">$votesFor</td>
				<td align="right">$movieInfo{$movieID}->{votesAgainst}</td>
				<td></td>
				<td valign="top">
		};
		if ( ($movieInfo{$movieID}->{statusShowing}) &&($movieInfo{$movieID}->{statusNew}) ){ print qq{<b>}; }
		print qq{
					<a href="
					javascript:window.open(
						'movie_view.cgi?movieID=$movieID',
						'ViewMovie',
						'resizable,height=350,width=450');
						index.cgi
					">$movieInfo{$movieID}->{title}</a></td>
				<td></td>
				<td>$movieInfo{$movieID}->{type}</td>
				<td></td>
				<td>$movieInfo{$movieID}->{votesHTML}</td>

			</tr>
		};

	}
}


##########################################################
#### The end.
##########################################################

