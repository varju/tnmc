#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/movies/';
require 'MOVIES.pl';

	################
	### Main Logic:
	&db_connect();

	my ($next_tuesday, $next_tuesday_string, $sql, $sth);

	$next_tuesday = &get_next_night();
	$sql = "SELECT DATE_FORMAT('$next_tuesday', 'W M D, Y')";
	$sth = $dbh_tnmc->prepare($sql);
	$sth->execute();
	($next_tuesday_string) = $sth->fetchrow_array();
	$sth->finish();

	&show_heading ("Movie for $next_tuesday_string");
	if (!&show_current_movie()){
		&show_movies($USERID);
	}




##########################################################
sub show_movies
{
	my ($effectiveUserID) = @_;

	if ($effectiveUserID){
		&list_my_attendance($effectiveUserID);
		
		print qq{
			<table cellpadding="0" cellspacing="0" border="0">
	                        <tr><th colspan="11" height="14">
	                                <form action="/movies/update_votes.cgi" method="post">
	                                <input type="hidden" name="userID" value="$effectiveUserID">
	                                &nbsp;now showing</th></tr>
		};
		show_movie_list($effectiveUserID, "WHERE (statusShowing AND NOT (statusSeen OR 0))");
		print qq{\n	</table><p>\n};
		
		print qq{
			<font face="verdana">
			<b>Favorite Movie:</b><br>
		};
		&show_favorite_movie_select($effectiveUserID);

		print qq{
			<br></font>
			<input type="image" border="0" src="/template/update_votes_submit.gif" alt="Update Votes">
			</form>
		};

	}else{
		print qq{
			<table cellpadding="0" cellspacing="0" border="0">
	                        <tr><th colspan="11" height="14">
	                                &nbsp;now showing</th></tr>
		};
		show_movie_list($effectiveUserID, "WHERE (statusShowing AND NOT (statusSeen OR 0))");
		print qq{\n	</table><p>\n};
	}
}


##########################################################
sub show_movie_list{

	my ($effectiveUserID, $whereClause, $junk) = @_;
	
	my (@movies, $anon, $movieID, %movieInfo);
	my ($boldNew, %vote_status_word, $vote, @list);

	&list_movies(\@list, $whereClause, 'ORDER BY title');
	foreach $movieID (@list){
		$anon = {}; 	### create an anonymous hash.
		&get_movie_extended($movieID, $anon);
		$movieInfo{$movieID} = $anon;
	}
	
        @list = sort  {       $movieInfo{$b}->{order}
                        <=>     $movieInfo{$a}->{order}}
                        @list ;

	foreach $movieID (@list){

                %vote_status_word = ();
                $vote = &get_vote($movieID, $effectiveUserID);
                $vote_status_word{$vote} = "CHECKED";
                
		print qq{
			<tr valign="top">
		};
		if ($effectiveUserID ){
			print qq{
				<td valign="top" nowrap><input type="radio" name="v$movieID" value="-1" $vote_status_word{'-1'}><input type="radio" name="v$movieID" value="0" $vote_status_word{'0'}><input type="radio" name="v$movieID" value="1" $vote_status_word{'1'} $vote_status_word{'2'}></td>
			};
		}
		print qq{
				<td align="right">&nbsp;&nbsp;$movieInfo{$movieID}->{rank}&nbsp;&nbsp;</td>
				<td valign="top">
		};
		if ($movieInfo{$movieID}->{statusNew}){ print qq{<b>}; }
		print qq{
					<a href="
					javascript:window.open(
						'/movies/movie_view.cgi?movieID=$movieID',
						'ViewMovie',
						'resizable,height=350,width=450');
						index.cgi
					">$movieInfo{$movieID}->{title}</a></td>
				<td>&nbsp;&nbsp;&nbsp;</td>
				<td>$movieInfo{$movieID}->{votesHTML}</td>

			</tr>
		};

	}
}

return 1;

##########################################################
#### The end.
##########################################################


