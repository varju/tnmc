##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

require 5.004;
use strict;
use DBI;
use CGI;

require 'db_access.pl';


##########################################################
sub show_movieMenu
{
	&db_connect();

	my %USER;
	&get_user($USERID, \%USER);

	print qq{
		<font face="verdana" size="-1" color="888888"><b>
	
		<a href="index.cgi">
		<font face="verdana" size="-1" color="888888"><b>
		Votes</b></font></a>

			&#149;

		<a href="attendance.cgi">
		<font face="verdana" size="-1" color="888888"><b>
		Attendance</b></font></a>

			&#149;

		<a href="list_seen_movies.cgi">
		<font face="verdana" size="-1" color="888888"><b>
		Seen</b></font></a>

			&#149;

		<a href="movie_add.cgi">
		<font face="verdana" size="-1" color="888888"><b>
		Add a Movie</b></font></a>

			&#149;

		<a href="help.cgi">
		<font face="verdana" size="-1" color="888888"><b>
		Information</b></font></a>
	};

	if ($USER{groupAdmin}){
		print qq{

			<br>

			<a href="list_all_movies.cgi">
			<font face="verdana" size="-1" color="888888"><b>
			All Movies</b></font></a>
			
			&#149;
			
			<a href="admin.cgi">
			<font face="verdana" size="-1" color="888888"><b>
			Admin</b></font></a>

			&#149;
			
			<a href="movies.cgi">
			<font face="verdana" size="-1" color="888888"><b>
			Testing</b></font></a>

		};
	}
	print qq{
		</b></font><br>
	};

}

##########################################################
sub show_favorite_movie_select{

	my ($effectiveUserID) = @_;
	my ($sql, $sth, @row, $favoriteMovie, $faveSel);

	print qq{
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
		</select>
	};
}

##########################################################
sub list_my_attendance{

	my ($userID) = @_;
    
    # Get User's attendance
    my %attendance;
    &get_attendance($userID, \%attendance);

    # Get the list of dates
    my @movieDates;
    foreach (keys %attendance){
	if (!/^movie(\d+)/) {next;}
	push (@movieDates, $1);
    }
    @movieDates = sort(@movieDates);

    # print some opening crap
    print qq{
	};

    print qq{
	<table border=0 cellpadding=1 cellspacing=0 width="100%">
	    <tr bgcolor="cccccc">
		<td norwrap>
		<form action="/movies/attendance_submit.cgi" method="post">
		<input type="hidden" name="userID" value="$userID">&nbsp;&nbsp;
		</td>
        <td align="center"><b>Default</td>
		<td>&nbsp;&nbsp;</td>
    };

    my $tuesdayDate;
    foreach $tuesdayDate (@movieDates){
	my $sql = "SELECT DATE_FORMAT('$tuesdayDate', '%b %D')";
	my $sth = $dbh_tnmc->prepare($sql);
	$sth->execute();
        my @row = $sth->fetchrow_array();
	
	print qq{
	    <td align="center"><font color="888888"><b>$row[0]&nbsp;</td>
		<td>&nbsp;&nbsp;</td>
	};
    }
    print qq{
		<td>&nbsp;&nbsp;</td>
		<td>&nbsp;&nbsp;</td>
	</tr>
	<tr>
		<td></td>
	        <td valign="top"><font size="-1">
		    <select name="movieDefault">
			<option value="$attendance{movieDefault}">$attendance{movieDefault}
			<option value="$attendance{movieDefault}">----
			<option>yes
			<option>no
		    </select></font>
		    </td>
		<td></td>
    };

    foreach $tuesdayDate (@movieDates){
	print qq{
	    <td valign="top"><font size="-1">
	    <select name="movie$tuesdayDate">
		<option value="$attendance{"movie$tuesdayDate"}">$attendance{"movie$tuesdayDate"}
		<option value="$attendance{"movie$tuesdayDate"}">----
		<option value="">Default
		<option>yes
		<option>no
	     </select>
		 </td>
		<td></td>
		};

    }
    print qq{
	<td valign="top"><font size="-1"><input type="submit" value="Set Attendance"></form></td>
	</tr>
	</table>
    };
}


################################################################################
sub show_current_movie
{
        
        my ($current_movie, $current_cinema, $current_showtime, $current_meeting_place, $current_meeting_time, $current_winner_blurb);
        my (%movie);
        
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
 
	$current_movie = get_general_config('movie_current_movie');
        $current_cinema = get_general_config('movie_current_cinema');
        $current_showtime = get_general_config('movie_current_showtime');
        $current_meeting_place = get_general_config('movie_current_meeting_place');
        $current_meeting_time = get_general_config('movie_current_meeting_time');
        $current_winner_blurb = get_general_config('movie_winner_blurb');

	$current_winner_blurb =~ s/\n/<br>/g;
	
        if (!$current_movie)
        {
	        print qq
                {
			<!-- no movie selected -->
                };
                return (0);
        }
	else{
	        %movie = {};
	        &get_movie($current_movie, \%movie);

                print qq{
		        <TABLE CELLSPACING=0 CELLPADDING=0 width="100">
                        <TR>
                        <TD colspan="2">$current_winner_blurb<p><br></TD>
                        </TR>

                        <TR>
                        <TD nowrap><B>Movie: </TD>
                        <TD nowrap>$movie{'title'}</TD>
                        </TR>
                        
                        <TR>
                        <TD nowrap><B>Cinema: </TD>
                        <TD nowrap>$current_cinema</TD>
                        </TR>

                        <TR>
                        <TD nowrap><B>Showtime: </TD>
                        <TD nowrap>$current_showtime</TD>
                        </TR>

                        <TR>
                        <TD nowrap><B>Meeting time: </TD>
                        <TD nowrap>$current_meeting_time</TD>
                        </TR>

                        <TR>
                        <TD nowrap><B>Meeting place: </TD>
                        <TD nowrap>$current_meeting_place</TD>
                        </TR>

                        </TABLE>
                        <P>
                };
		return (1);
	}
}

###################################################################
sub set_attendance{
	my (%attendance, $junk) = @_;
	my ($sql, $sth, $return);
	
	&db_set_row(\%attendance, $dbh_tnmc, 'MovieAttendance', 'userID');
}

###################################################################
sub get_attendance{
	my ($userID, $attendance_ref, $junk) = @_;
	my ($condition);

	$condition = "userID = '$userID'";
	&db_get_row($attendance_ref, $dbh_tnmc, 'MovieAttendance', $condition);
}

###################################################################
sub set_night{
	my (%night, $junk) = @_;
	my ($sql, $sth, $return);
	
	&db_set_row(\%night, $dbh_tnmc, 'MovieNights', 'nightID');

	if (!$night{nightID}){
		$sql = "SELECT nightID FROM MovieNights WHERE date = " . $dbh_tnmc->quote($night{date});
		$sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
		$sth->execute;
		($return) = $sth->fetchrow_array();
		$sth->finish;
	}else{
		$return = $night{nightID};
	}
	return $return;
}

###################################################################
sub get_night{
	my ($nightID, $night_ref, $junk) = @_;
	my ($condition);

	$condition = "(nightID = '$nightID' OR date = '$nightID')";
	print $condition;
	&db_get_row($night_ref, $dbh_tnmc, 'MovieNights', $condition);
}

###################################################################
sub get_next_night{
	my ($date, $junk) = @_;
	my ($sql, $sth, $return);

	if (!$date){
		$sql = "SELECT DATE_FORMAT(NOW(), '%Y%m%d')";
		$sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
		$sth->execute;
		($date) = $sth->fetchrow_array();
	}

	$sql = "SELECT DATE_FORMAT(date, '%Y%m%d') FROM MovieNights WHERE date >= '$date' LIMIT 1";
	$sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
	$sth->execute;
	($return) = $sth->fetchrow_array();
	
	return $return;
}

###################################################################
sub get_next_nightID{
	my ($junk) = @_;
	my ($sql, $sth, $return);

	$sql = "SELECT nightID FROM MovieNights WHERE date >= DAVE_FORMAT(NOW(), %Y%m%d') ORDER BY nightID LIMIT 1";
	$sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
	$sth->execute;
	($return) = $sth->fetchrow_array();

	return $return;
}

###################################################################
sub set_movie{
	my (%movie, $junk) = @_;
	my ($sql, $sth, $return);
	
	&db_set_row(\%movie, $dbh_tnmc, 'Movies', 'movieID');
	
	###############
	### Return the Movie ID
	
	$sql = "SELECT movieID FROM Movies WHERE title = " . $dbh_tnmc->quote($movie{title});
	$sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
	$sth->execute;
	($return) = $sth->fetchrow_array();
	$sth->finish;
	
	return $return;
}

###################################################################
sub get_movie{
	my ($movieID, $movie_ref, $junk) = @_;
	my ($condition);

	$condition = "(movieID = '$movieID' OR title = '$movieID')";
	&db_get_row($movie_ref, $dbh_tnmc, 'Movies', $condition);
}

##########################################################
sub get_movie_extended{

	my ($movieID, $movie, $userID, $junk) = @_;

	### Get basic info.
       	&get_movie($movieID, $movie);


	my $thisTues = &get_next_night();
	my $nextTues = &get_next_night($thisTues);
	
	my ($sql, $sth, @row);

	$sql = "SELECT p.userID, p.username, v.type,
                       DAYOFYEAR(p.birthdate) - DAYOFYEAR($thisTues),
                       a.movieDefault, a.movie$thisTues, a.movie$nextTues
                 FROM           MovieVotes as v
                      LEFT JOIN Personal as p USING (userID)
                      LEFT JOIN MovieAttendance as a USING (userID)
		WHERE v.movieID = '$movieID'
		ORDER BY p.username ASC";

	$sth = $dbh_tnmc->prepare($sql);
	$sth->execute();

	my ($VuserID, $Vperson, $Vtype, $Ubday, $Udefault, $Uthis, $Unext);

	# find out who voted for the movie...
	while (@row = $sth->fetchrow_array()){


		$VuserID = $row[0];
		$Vperson = $row[1];
		$Vtype = $row[2];
		$Ubday = $row[3];
		$Udefault = $row[4];
		$Uthis = $row[5];
		$Unext = $row[6];

		if ( ($Vperson eq 'demo')
		   && ($USERID != 38)){
			#
			# Do nothing
			#
		}
			
		elsif (	($Uthis eq 'no')
			|| ($Uthis eq '' and $Udefault eq 'no')	){

			if (	($Unext eq 'no')
				|| ($Unext eq '' and $Udefault eq 'no')	){

				if ($Vtype >= 1){
					$movie->{votesHTML} .= "<font color='cccccc'>$Vperson</font> ";
					$movie->{votesText} .= "[$Vperson] ";
					$movie->{votesForLost} ++;
				}
			}
			elsif ($Vtype == 1){
				$movie->{votesHTML} .= "<font color='888888'>$Vperson</font> ";
				$movie->{votesText} .= "[$Vperson] ";
				$movie->{votesForAway} ++;
			}
			elsif ($Vtype == 2){
				$movie->{votesHTML} .= "<font color='888888'><b>$Vperson</b></font> ";
				$movie->{votesText} .= "[$Vperson!] ";
				$movie->{votesFaveAway} ++;
			}
		}
		elsif ($Vtype == 2){
		    if ($Ubday ne '' && $Ubday <= 3 && $Ubday >= -3){
			$movie->{votesHTML} .= "<b><font style='background-color: #ff88ff'>&nbsp;$Vperson&nbsp;</font></b> ";
			$movie->{votesText} .= "***${Vperson}*** ";
			$movie->{votesFaveBday} ++;
			
		    }else{
			$movie->{votesHTML} .= "<b>$Vperson</b> ";
			$movie->{votesText} .= "${Vperson}! ";
			$movie->{votesFave} ++;
		    }
		}
		elsif ($Vtype == 1){
			$movie->{votesHTML} .= "$Vperson ";
			$movie->{votesText} .= "${Vperson} ";
			$movie->{votesFor} ++;
		}
		elsif ($Vtype == -1){
			$movie->{votesHTML} .= "<font color='ff2222'>$Vperson</font> ";
			$movie->{votesText} .= "(${Vperson}) ";
			$movie->{votesAgainst} ++;
		}

	}
	$sth->finish();


	### Do the rank stuff
	$movie->{order} += 1.0 *  $movie->{votesFor};
	$movie->{order} += 1.5 *  $movie->{votesFave};
	$movie->{order} += 10  *  $movie->{votesFaveBday};
	$movie->{order} -= 0.5 *  $movie->{votesAgainst};
	$movie->{order} -= 0.4 *  $movie->{votesForAway};
	$movie->{order} -= 0.8 *  $movie->{votesFaveAway};

	# encourage movies with good ratings!
	my $rating = $movie->{rating};
	if ($rating != 0){
		$rating -= 2.5;
		if ($rating >= 1){
			$movie->{order} *=     1 + ( $rating / 5 );
		}else{
			$movie->{order} +=        $rating;
		}
	}

	### stoopid f---ed up rounding math.
	$movie->{rank} = $movie->{order};
	if ($movie->{rank} > 0)	{	$movie->{rank} += 0.5; }
	$movie->{rank} = int($movie->{rank});

}

###################################################################
sub del_movie{
	my ($movieID) = @_;
	my ($sql, $sth, $return);
	
	###############
	### Delete the movie
	
	$sql = "DELETE FROM Movies WHERE movieID = '$movieID'";
	$sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
	$sth->execute;
	$sth->finish;
}

###################################################################
sub list_movies{
	my ($movie_list_ref, $where_clause, $by_clause, $junk) = @_;
	my (@row, $sql, $sth);

	@$movie_list_ref = ();

	$sql = "SELECT movieID from Movies $where_clause $by_clause";
	$sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
	$sth->execute;
	while (@row = $sth->fetchrow_array()){
		push (@$movie_list_ref, $row[0]);
	}
	$sth->finish;

	return $#$movie_list_ref;
}

###################################################################
sub list_votes_by_movie{
        my ($votes_list_ref, $movieID, $stats_ref, $junk) = @_;
        my (@row, $sql, $sth, $return, $userID, %user, $vote);

        @$votes_list_ref = ();
        %$stats_ref = ();
        $return = '0';

        $sql = "SELECT Personal.userID, type 
		  FROM MovieVotes, Personal
		 WHERE movieID = '$movieID'
		   AND MovieVotes.userID = Personal.userID
		 ORDER BY username";
        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
        $sth->execute;
        while (@row = $sth->fetchrow_array()){
                ($userID, $vote, $junk) = @row;
                push (@$votes_list_ref, $userID);

                if ($vote > 0) { $return += $vote; }
                else           { $return += $vote / 2; }

        }
        $sth->finish;
        
        return $return;
}


###################################################################
sub get_vote{
        my ($movieID, $userID, $junk) = @_;
        my ($sql, $sth, @row, $vote);

        $sql = "SELECT type from MovieVotes WHERE movieID = '$movieID' AND userID = '$userID'";
        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
        $sth->execute;
        @row = $sth->fetchrow_array();
        $sth->finish;

        $vote = $row[0];

        if(!$vote){
                $vote = '0';
        }
        return $vote;
}

###################################################################
sub set_vote{
        my ($movieID, $userID, $type, $junk) = @_;
        my ($sql, $sth);

        $sql = "DELETE FROM MovieVotes WHERE movieID='$movieID' AND userID='$userID'";
        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
        $sth->execute;
        $sth->finish;

        $sql = "REPLACE INTO MovieVotes (movieID, userID, type) VALUES($movieID, $userID, $type)";
        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
        $sth->execute;
        $sth->finish;
}


# keepin perl happy...
return 1;

