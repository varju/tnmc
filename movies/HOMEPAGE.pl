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

	&get_user($USERID, \%USER);

	$current_movie =  &get_general_config("movie_current_movie");
	if ($current_movie){
	        &show_current_movie();
        }
	else{
		&show_movies();
	}

	&db_disconnect();

##########################################################
sub show_movies
{

        my $sql = "SELECT DATE_ADD(NOW(), INTERVAL ((9 - DATE_FORMAT(NOW(), 'w') ) % 7) DAY)";
        my $sth = $dbh_tnmc->prepare($sql);
        $sth->execute();
        my ($next_tuesday) = $sth->fetchrow_array();
        $sth->finish();

        $sql = "SELECT DATE_FORMAT('$next_tuesday', 'W M D, Y')";
        $sth = $dbh_tnmc->prepare($sql);
        $sth->execute();
        my ($next_tuesday_string) = $sth->fetchrow_array();
        $sth->finish();

	&show_heading ("Votes for $next_tuesday_string");

	##################################################################
	### Start of list

	print qq{
		<table cellpadding="0" cellspacing="0" border="0">
		<tr  bgcolor="ffffff">
	};
	if ($USERID) { print qq{
			<td align="center">
		<form action="/movies/update_votes.cgi" method="post">
		<input type="hidden" name="userID" value="$USERID">
				<b>N &nbsp;&nbsp; ? &nbsp;&nbsp; Y</b></td>
	};}
	print qq{
			<td><b>&nbsp;&nbsp;&nbsp;#&nbsp;&nbsp;&nbsp;&nbsp;</b></td>
			<td><b>Title</b></td>
			<td><b>Votes</b></td>
			</tr>
	};

	show_movie_list( "WHERE (m.statusShowing AND NOT (m.statusSeen OR 0))");

	print qq{\n	</table><p>\n};


	### End of list
	##################################################################
	if ($USERID){

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
	                WHERE userID = '$USERID' AND type = '2'";
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
	                if ($favoriteMovie == $row[0]){		$faveSel = 'selected';}
	                else{                   		$faveSel = '';}
	                print qq{               <option value="$row[0]" $faveSel>$row[1]\n};
	        }
	        $sth->finish;
	                        
	        print qq{
	                </select><br>           
	        };
  

		print qq{
			<input type="image" border="0" src="/template/update_votes_submit.gif" alt="Update Votes">
			</form>
		};
	}
}

##########################################################
sub show_movie_list{

	($whereClause, $junk) = @_;

	$sql = "SELECT m.movieID, m.title, m.statusNew,
		       p.username, v.type, p.movieAttendance
                 FROM           Movies as m 
                      LEFT JOIN MovieVotes as v USING (movieID)
                      LEFT JOIN Personal as p USING (userID)
		$whereClause
		ORDER BY m.title ASC, p.username ASC";

	$sth = $dbh_tnmc->prepare($sql);
	$sth->execute();

	@row = $sth->fetchrow_array();
	$movieID = 0;

	while ( $row[0] ){

		#   0          1        2            3           4       5
		# m.movieID, m.title, m.statusNew, p.username, v.type, p.movieAttendance

		$movieID = $row[0];

		$title{$movieID} = $row[1];
		$statusNew{$movieID} = $row[2];
		$votes{$movieID} = '';
 		$votesFor{$movieID} = 0;
		$votesAgainst{$movieID} = 0;

		# find out who voted for the movie...
		while ($row[0] == $movieID){
			$Vperson = $row[3];
			$Vtype = $row[4];
			$Vstatus = $row[5];

                       if ( ($Vperson eq 'demo')
                           && ($effectiveUserID != 38)){        
                                # 
                                # Do nothing
                                #
                        }
                        elsif (!$Vstatus){
				if ($Vtype == 1){
					$votes{$movieID} .= "<font color='888888'>$Vperson</font> ";
					$votesAgainst{$movieID} ++;
				}
				if ($Vtype == 2){
					$votes{$movieID} .= "<font color='888888'><b>$Vperson</b></font> ";
					$votesAgainst{$movieID} += 2;
				}
			}
			elsif ($Vtype == 2){
				$votes{$movieID} .= "<b>$Vperson</b> ";
				$votesFor{$movieID} += 2;
			}
			elsif ($Vtype == 1){
				$votes{$movieID} .= "$Vperson ";
				$votesFor{$movieID} ++;
			}
			elsif ($Vtype == -1){
				$votes{$movieID} .= "<font color='ff2222'>$Vperson</font> ";
				$votesAgainst{$movieID} ++;
			}

			@row = $sth->fetchrow_array();
		}

		$order{$movieID} = $votesFor{$movieID} - ($votesAgainst{$movieID} / 2);

                ### stoopid f---ed up rounding math.
		$rank{$movieID} = $order{$movieID};
		if ($rank{$movieID} > 0) { $rank{$movieID} += 0.5; }
		$rank{$movieID} = int($rank{$movieID});
   	}

	$sth->finish();

	@movies = keys(%rank);
        @movies = sort  {       $order{$b}
                        <=>     $order{$a}}
                        @movies ;

	foreach $movieID (@movies){

		print qq{	<tr valign="top">};

		if ($USERID){
        	        %vote_status_word = ();
                	$vote = &get_vote($movieID, $USERID);
                	$vote_status_word{$vote} = "CHECKED";
			print qq{ 	<td valign="top" nowrap><input type="radio" name="v$movieID" value="-1" $vote_status_word{'-1'}><input type="radio" name="v$movieID" value="0" $vote_status_word{'0'}><input type="radio" name="v$movieID" value="1" $vote_status_word{'2'} $vote_status_word{'1'}></td>};
		}

		if ($statusNew{$movieID}) { $boldNew = '<b>'; }
		else 			  { $boldNew = ''; }

		print qq{
				<td>&nbsp;&nbsp;$rank{$movieID}</td>
				<td nowrap valign="top">$boldNew<a href="javascript:window.open(
					'/movies/movie_view.cgi?movieID=$movieID',
					'ViewMovie',
					'resizable,height=500,width=550');
					index.cgi
					">$title{$movieID}
				</a>&nbsp;&nbsp;</td>
				<td>$votes{$movieID}</td>
			</tr>
		};
	}
}

return 1;

##########################################################
#### The end.
##########################################################


