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
	        <td valign="top"><b>
		    <select name="movieDefault">
			<option value="$attendance{movieDefault}">$attendance{movieDefault}
			<option value="$attendance{movieDefault}">----
			<option>yes
			<option>no
		    </select>
		    </td>
		<td></td>
    };

    foreach $tuesdayDate (@movieDates){
	print qq{
	    <td valign="top">
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
	<td valign="top"><b><input type="submit" value="Update"></form></td>
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
	
        if (!$current_movie)
        {
	        print qq
                {
			<!-- no movie selected -->
                };
                return;
        }
        %movie = {};
        &get_movie($current_movie, \%movie);

	        &show_heading ("Movie for $next_tuesday_string");

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
# sub show_current_tally_email{
#
#        my ($movieID, %movie, @movies, @votes, $vote, $num_votes, $userID, %user, @junk);
#
#        print "\nnew releases:\n============\n";
#        list_movies(\@movies, "WHERE status = 'just released'", '');
#
#        foreach $movieID (@movies){
#                get_movie($movieID, \%movie);
#                $num_votes = list_votes_by_movie(\@votes, $movieID);
#                print "$movie{title} \n $movie{description}\n\n";
#        }
#
#        print "\nnow showing:\n============\n";
#        list_movies(\@movies, "WHERE status = 'showing' OR status = 'just released'", '');
#
#        @movies = sort  {       list_votes_by_movie(\@junk, $b)
#                        <=>     list_votes_by_movie(\@junk, $a)}
#                        @movies ;
#        foreach $movieID (@movies){
#                get_movie($movieID, \%movie);
#                $num_votes = list_votes_by_movie(\@votes, $movieID);
#                print "$num_votes  $movie{title} \t{ ";
#                foreach $userID (@votes){
#                        &get_user($userID, \%user); 
#                        $vote = &get_vote($movieID, $userID);
#                        if ($vote > 0){         print "$user{username} ";       }                       
#                        if ($vote < 0){         print "!$user{username} ";      }
#                }
#                print "}\n";
#        }
#
#        print "\ncoming soon:\n============\n";
#        list_movies(\@movies, "WHERE status = 'coming soon'", '');
#        @movies = sort  {       list_votes_by_movie(\@junk, $b)
#                        <=>     list_votes_by_movie(\@junk, $a)}
#                        @movies ;
#        foreach $movieID (@movies){
#                get_movie($movieID, \%movie);
#                $num_votes = list_votes_by_movie(\@votes, $movieID);
#                print "$num_votes  $movie{title}\n        { ";
#                foreach $userID (@votes){
#                        &get_user($userID, \%user);
#                        $vote = &get_vote($movieID, $userID);
#                        if ($vote > 0){         print "$user{username} ";       }
#                        if ($vote < 0){         print "!$user{username} ";      }
#                }
#                print "}\n";
#        }
#
# }
#
####################################################################
# sub get_vote_stats{
#        my ($stats_ref, $movieID, $junk) = @_;
#        my (@row, $sql, $sth, $return, $vote, $userID, %user);
#
#        %$stats_ref = {};
#        $return = '0';
#
#        $sql = "SELECT userID, type from MovieVotes where movieID = '$movieID'";
#        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
#        $sth->execute;
#        while (@row = $sth->fetchrow_array()){
#                ($userID, $vote, $junk) = @row;
#                &get_user($userID, \%user);
#
#                if ($user{status} eq 'inactive'){
#                        next;
#                }
#                elsif ($user{status} eq 'active'){
#                        $stats_ref->{$vote} += 1;
#                }
#        
#                elsif ($user{status} eq 'away') {       
#                        if ($vote > 0){
#                                $stats_ref->{'away'} += 1;
#                        }
#                }
#        }
#        $sth->finish;
#
#        return $return;
# }
#
####################################################################
# sub show_current_tally{
#        my ($userID, $junk) = @_;
#        my ($movieID, %movie, @movies, @movies_temp, %user, @votes, $num_votes, %vote_status_word, $vote, @junk, %vote_stats);
#
#        if ($userID){
#                print qq
#                {
#                        <form action="update_votes.cgi" method="post">
#                };
#        }
#        print qq
#        {
#                <input type="hidden" name="userID" value="$userID">
#                <table border="0" cellpadding="0" cellspacing="2">
#        };
#
#        @movies = ();
#
#        &list_movies(\@movies_temp, "WHERE status='just released'", '');
#        @movies = (@movies, @movies_temp);
#
#        &list_movies(\@movies_temp, "WHERE status='showing'", '');
#        @movies = (@movies, @movies_temp);
#        @movies = sort  {       list_votes_by_movie(\@junk, $b)
#                        <=>     list_votes_by_movie(\@junk, $a)}
#                        @movies ;
#
#
#        if ($userID)
#        {        print qq
#                {       <tr valign="top">
#                        <td align="center"> <b>N</td>
#                        <td align="center"> <b>?</td>
#                        <td align="center"> <b>Y</td>
#
#                        <td>&nbsp&nbsp</td>
#                };
#        }
#
#        print qq
#        {       <td><b> # </td>
#
#                <td>&nbsp&nbsp</td>
#
#                <td><b>Movie</td>
#                <td>&nbsp&nbsp&nbsp</td>
#                <td><b>Votes</td>
#                </tr>
#        };
#
#        my $max_votes = 0;
#
#        foreach $movieID (@movies)
#        {
#                get_movie($movieID, \%movie);
#
#                $num_votes = list_votes_by_movie(\@votes, $movieID, \%vote_stats);
#                if ($movie{'status'} eq "just released")
#                {       $movie{'title'} = "<B>$movie{'title'}</B>";
#                }
#
#                ### stoopid f---ed up rounding math.
#                if ($num_votes > 0) { $num_votes += 0.5; }
#                $num_votes = int($num_votes);
#                %vote_status_word = ();
#                $vote = &get_vote($movieID, $userID);
#                $vote_status_word{$vote} = "CHECKED";
#
#                if ($userID)
#                {       print qq{
#                                <tr valign="top">
#                                <td valign="top"><input type="radio" name="v$movieID" value="-1" $vote_status_word{'-1'}></td>
#                                <td valign="top"><input type="radio" name="v$movieID" value="0" $vote_status_word{'0'}></td>
#                                <td valign="top"><input type="radio" name="v$movieID" value="1" $vote_status_word{'1'}></td>
#                                <td></td>
#                        };
#                }
#                print qq
#                {
#                        <td valign="top" nowrap>$num_votes</td>
#                                <td></td>
#                                <td nowrap valign="top"><a href="
#                                        javascript:window.open(
#                                                'movie_view.cgi?movieID=$movieID',
#                                                'ViewMovie',
#                                                'noresizable,height=500,width=550');
#                                                index.cgi
#                                        ">$movie{title}</a></td>
#
#                                <td valign="top"></td>
#                                <td valign="top">
#                };
#
#                        foreach $userID (@votes){
#                                &get_user($userID, \%user);
#                                $vote = &get_vote($movieID, $userID);
#                                ### output control:
#                                if ($user{'status'} eq 'inactive'){
#                                        next;
#                                }
#        
#                                ### username / vote-type
#                                if ($vote > 0){
#                                        print "$user{username} ";
#                                }
#                                elsif ($vote < 0){
#                                        print "!$user{username} ";
#                                }
#                        }
#
#                print qq{
#                                </td>
#                        </tr>
#                };
#        }
#
#        print qq{
#                </table>
#                <P>
#        };
#        if ($USERID){
#                print qq{
#                        <input type="image" border=0 src="template/update_votes_submit.gif" alt="Update Votes">
#                        </form>
#                };
#        }
# }
#
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

