package tnmc::movies::movie;

use strict;

#
# module configuration
#
BEGIN{
    use tnmc::db;
    use tnmc::security::auth;
    
    require Exporter;
    use vars qw(@ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(Exporter);
    @EXPORT = qw(set_movie get_movie get_movie_extended get_movie_extended2 del_movie);
    @EXPORT_OK = qw();
}

#
# module routines
#

sub list_active_movie_titles{
    my %list;
    
    my $sql = "SELECT movieID, title
             FROM Movies
            WHERE statusShowing = '1' AND statusSeen != '1' AND statusBanned != 1
            ";
    
    my $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();
    
    while (my @row = $sth->fetchrow_array()){
        $list{$row[1]} = $row[0];
    }
    $sth->finish;
    
    return \%list;
}


sub set_movie{
    my (%movie, $junk) = @_;
    my ($sql, $sth, $return);
    
    &tnmc::db::db_set_row(\%movie, $dbh_tnmc, 'Movies', 'movieID');
    
    ###############
    ### Return the Movie ID
    
    $sql = "SELECT movieID FROM Movies WHERE title = " . $dbh_tnmc->quote($movie{title});
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    ($return) = $sth->fetchrow_array();
    $sth->finish;
    
    return $return;
}

sub get_movie{
    my ($movieID, $movie_ref, $junk) = @_;
    my ($condition);
    
    my $sql = "SELECT * FROM Movies WHERE movieID = ?";
    my $sth = $dbh_tnmc->prepare($sql)
        or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute($movieID);
    my $ref = $sth->fetchrow_hashref();
    $sth->finish;
    %$movie_ref = %$ref;
    
}

{
    my (%cache_attendance);
sub get_movie_extended2{
    my ($movieID, $movie, $nightID) = @_;
    
    require tnmc::movies::attendance;
    require tnmc::movies::vote;
    require tnmc::user;
    
    ### Get basic info.
    &get_movie($movieID, $movie);
    
    ## Fudge the theatre list into something human-readable
    require tnmc::movies::theatres;
    my @theatres = split(/\s/, $movie->{'theatres'});
    
    foreach my $theatreid (@theatres){
        my $theatre = &tnmc::movies::theatres::get_theatre_by_mybcid($theatreid);
        $movie->{'theatres_string'} .= " " . $theatre->{'name'};
        $movie->{'theatres_url'} .= " <a href=\"http://www2.mybc.com/movies/theatres/$theatre->{'mybcid'}.html\">$theatre->{'name'}</a>";
    }
    
    # get the attendance list
    my $attendance;
    if ($nightID){
        if (!$cache_attendance{$nightID}){
            $cache_attendance{$nightID} = &tnmc::movies::attendance::get_night_attendance_hash($nightID);
        }
        $attendance = $cache_attendance{$nightID};
    }
    else{
        my @all_users;
        &tnmc::user::list_users(\@all_users);
        $attendance = {map {($_, '1')} (@all_users)};
    }
    my @users = grep {$attendance->{$_} && $attendance->{$_} >= -1} (keys %$attendance);
    
    
    # get the votes 
    my $votes = &tnmc::movies::vote::get_movie_votes_hash($movieID, \@users);
    
    # initialize some values
    $movie->{votesFor} = 0;
    $movie->{votesFave} = 0;
    $movie->{votesSuperfave} = 0;
    $movie->{votesBday} = 0;
    $movie->{votesAgainst} = 0;
    $movie->{votesForAway} = 0;
    $movie->{votesFaveAway} = 0;
    $movie->{votesForLost} = 0;
    $movie->{votesHTML} = '';
    $movie->{votesText} = '';
    my %votesHTML;
    my %votesText;
    
    # analyze the votes
    foreach my $userID (keys %$votes){
        
        my $type = $votes->{$userID};
        
        # skip empty votes
        next if !$type;
        
        # skip demo user
        next if (($userID == 38) && ($USERID != 38));
        
        # get user info
        my $user = &tnmc::user::get_user_cache($userID);
        
        my $username = $user->{'username'};
        my $attend = $attendance->{$userID};
        my $bday = 0;        # assume no birthdays
        
        # evaluate the vote
        if ($attend  == -1){
            if (!$user->{'movieAttendanceDefault'}){
                if ($type >= 1){
                    $votesHTML{$username} = "<font color='cccccc'>$username</font>";
                    $votesText{$username} = "[$username] ";
                    $movie->{votesForLost} ++;
                }
            }
            elsif ($type == 1){
                $votesHTML{$username} = "<font color='888888'>$username</font>";
                $votesText{$username} = "[$username] ";
                $movie->{votesForAway} ++;
            }
            elsif ($type >= 2){
                $votesHTML{$username} = "<font color='888888'><b>$username</b></font>";
                $votesText{$username} = "[$username!] ";
                $movie->{votesFaveAway} ++;
            }
        }else{
            if ($type == 1){
                $votesHTML{$username} = $username;
                $votesText{$username} = $username;
                $movie->{votesFor} ++;
            }
            elsif ($type == -1){
                $votesHTML{$username} = "<font color='ff2222'>$username</font>";
                $votesText{$username} = "(${username})";
                $movie->{votesAgainst} ++;
            }
            elsif ($type == 2){
                $votesHTML{$username} = "<b>$username</b>";
                $votesText{$username} = "${username}!";
                $movie->{votesFave} ++;
            }
            elsif ($type == 3){
                $votesHTML{$username} = "<b><font style='background-color: #ffff88'>&nbsp;$username&nbsp;</font></b>";
                $votesText{$username} = "**${username}**";
                $movie->{votesSuperfave} ++;
            }
            elsif ($type == 4){
                $votesHTML{$username} = "<b><font style='background-color: #ff88ff'>&nbsp;$username&nbsp;</font></b>";
                $votesText{$username} = "***${username}***";
                $movie->{votesBday} ++;
            }
        }
    }
    
    $movie->{'votesHTML'} = join(' ', map {$votesHTML{$_}} (sort keys %votesHTML));
    $movie->{'votesText'} = join(' ', map {$votesText{$_}} (sort keys %votesText));
    
    ### Do the rank stuff
    $movie->{order} += 1.0 *  $movie->{votesFor};
    $movie->{order} += 1.5 *  $movie->{votesFave};
    $movie->{order} += 5   *  $movie->{votesSuperfave};
    $movie->{order} += 10  *  $movie->{votesBday};
    $movie->{order} -= 0.5 *  $movie->{votesAgainst};
    $movie->{order} -= 0.4 *  $movie->{votesForAway};
    $movie->{order} -= 0.8 *  $movie->{votesFaveAway};
    
    $movie->{votesForTotal} = $movie->{votesFor}
                            + $movie->{votesFave}
                            + $movie->{votesSuperFave}
                            + $movie->{votesBday};
    $movie->{votesAway} = $movie->{votesFaveAway}
                        + $movie->{votesForAway}
                        + $movie->{votesForLost};
    
    ### stoopid f---ed up rounding math.
    $movie->{rank} = $movie->{order};
    if ($movie->{rank} > 0)    {    $movie->{rank} += 0.5; }
    $movie->{rank} = int($movie->{rank});
    
}
}

sub get_movie_extended{
    my ($movieID, $movie, $userID, $junk) = @_;
    
    require tnmc::movies::night;
    
    
    ### Get basic info.
    &get_movie($movieID, $movie);


    ## Fudge the theatre list into something human-readable
    require tnmc::movies::theatres;
    my @theatres = split(/\s/, $movie->{'theatres'});
    
    foreach my $theatreid (@theatres){
        my $theatre = &tnmc::movies::theatres::get_theatre_by_mybcid($theatreid);
        $movie->{'theatres_string'} .= " " . $theatre->{'name'};
        $movie->{'theatres_url'} .= " <a href=\"http://www2.mybc.com/movies/theatres/$theatre->{'mybcid'}.html\">$theatre->{'name'}</a>";
    }
        
 
    my $thisTues = &tnmc::movies::night::get_next_night();
    my $nextTues = &tnmc::movies::night::get_next_night($thisTues);
    
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

    # initialize some values
    $movie->{votesFor} = 0;
    $movie->{votesFave} = 0;
    $movie->{votesFaveBday} = 0;
    $movie->{votesAgainst} = 0;
    $movie->{votesForAway} = 0;
    $movie->{votesFaveAway} = 0;
    $movie->{votesForLost} = 0;
    $movie->{votesHTML} = '';
    $movie->{votesText} = '';

    # find out who voted for the movie...
    while (@row = $sth->fetchrow_array()){

        $VuserID = $row[0] || '';
        $Vperson = $row[1] || '';
        $Vtype = $row[2] || 0;
        $Ubday = $row[3];
        $Udefault = $row[4] || '';
        $Uthis = $row[5] || '';
        $Unext = $row[6] || '';

        if ( ($USERID != 38)
                     && ($Vperson eq 'demo') ){

            #
            # Do nothing
            #
        }
            
        elsif (    ($Uthis eq 'no')
            || ($Uthis eq '' and $Udefault eq 'no')    ){

            if (    ($Unext eq 'no')
                || ($Unext eq '' and $Udefault eq 'no')    ){

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
        elsif ($Vtype == 3){
            $movie->{votesHTML} .= "<b><font style='background-color: #ffff88'>&nbsp;$Vperson&nbsp;</font></b> ";
            $movie->{votesText} .= "**[$Vperson!** ";
            $movie->{votesSuperfave} ++;
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
    $movie->{order} += 5   *  $movie->{votesSuperfave};
    $movie->{order} += 1.5 *  $movie->{votesFave};
    $movie->{order} += 10  *  $movie->{votesFaveBday};
    $movie->{order} -= 0.5 *  $movie->{votesAgainst};
    $movie->{order} -= 0.4 *  $movie->{votesForAway};
    $movie->{order} -= 0.8 *  $movie->{votesFaveAway};

    $movie->{votesForTotal} = $movie->{votesFave}
                                + $movie->{votesFor}
                                + $movie->{votesFaveBday};
    $movie->{votesAway} = $movie->{votesFaveAway}
                            + $movie->{votesForAway}
                            + $movie->{votesForLost};

    ### stoopid f---ed up rounding math.
    $movie->{rank} = $movie->{order};
    if ($movie->{rank} > 0)    {    $movie->{rank} += 0.5; }
    $movie->{rank} = int($movie->{rank});

}

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


1;



