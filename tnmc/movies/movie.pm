package tnmc::movies::movie;

use strict;

use tnmc::db;
use tnmc::security::auth;

#
# module configuration
#

my $table = "Movies";
my $key = "movieID";

#
# module routines
#

sub list_active_movie_titles{
    my %list;
    
    my $sql = "SELECT movieID, title
             FROM Movies
            WHERE statusShowing = '1' AND statusSeen != '1' AND statusBanned != 1
            ";
    
    my $dbh = &tnmc::db::db_connect();
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    
    while (my @row = $sth->fetchrow_array()){
        $list{$row[1]} = $row[0];
    }
    $sth->finish;
    
    return \%list;
}

sub set_movie{
    if (scalar(@_) == 1){
	## NEW-STYLE
	# usage: &set_movie($movie_hash);
	return &tnmc::db::item::replaceItem($table, $key, $_[0]);
    }
    else{
	## OLD-STYLE
	my (%movie, $junk) = @_;
	my ($sql, $sth, $return);
	
	my $dbh = &tnmc::db::db_connect();
	&tnmc::db::db_set_row(\%movie, $dbh, 'Movies', 'movieID');
	
	###############
	### Return the Movie ID
	
	my $dbh = &tnmc::db::db_connect();
	$sql = "SELECT movieID FROM Movies WHERE title = " . $dbh->quote($movie{title});
	$sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
	$sth->execute;
	($return) = $sth->fetchrow_array();
	$sth->finish;
	
	return $return;
    }
}

sub new_movie{
    # usage: my $movie_hash = &new_movie($movieID);
    return &tnmc::db::item::newItem($table, $key);
}

sub add_movie{
    # usage: my $movieID = &add_movie($movie_hash);
    return &tnmc::db::item::addItem($table, $key, $_[0]);
}

sub get_movie{
    if (scalar(@_) == 1){
	## NEW-STYLE
	# usage: my $movie_hash = &get_movie($movieID);
	return &tnmc::db::item::getItem($table, $key, $_[0]);
    }
    else{
	## OLD-STYLE
	
	my ($movieID, $movie_ref, $junk) = @_;
	my ($condition);
	
	my $sql = "SELECT * FROM Movies WHERE movieID = ?";
	my $dbh = &tnmc::db::db_connect();
	my $sth = $dbh->prepare($sql)
	    or die "Can't prepare $sql:$dbh->errstr\n";
	$sth->execute($movieID);
	my $ref = $sth->fetchrow_hashref();
	$sth->finish;
	%$movie_ref = %$ref;
    }
}

sub get_movie_by_filmcanid{
    # usage: my $movie_hash = &get_movie($filmcanid);
    return &tnmc::db::item::getItem($table, "filmcanID", $_[0]);
}

sub get_movie_by_imdbid{
    # usage: my $movie_hash = &get_movie($filmcanid);
    return &tnmc::db::item::getItem($table, "imdbID", $_[0]);
}

sub get_movie_by_mybcid{
    # usage: my $movie_hash = &get_movie($mybcid);
    return &tnmc::db::item::getItem($table, "mybcID", $_[0]);
}

sub reformat_title{
    my ($title) = @_;
    
    $title =~ s/^(A|The|An) (.*)$/$2\, $1/i;
    return $title;
}

sub get_movieid_by_title{
    my ($title) = @_;
    
    my $dbh = &tnmc::db::db_connect();

    my $sql = "SELECT movieID FROM Movies
                 WHERE title = ?";
    my $sth = $dbh->prepare($sql);
    $sth->execute($title);
    my @row = $sth->fetchrow_array();
    $sth->finish();
    
    return $row[0];
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
        $movie->{'theatres_url'} .= " <a href=\"http://www.mytelus.com/movies/tdetails.do?theatreID=$theatre->{'mybcid'}\">$theatre->{'name'}</a>";
    }
    
    ## Fudge the statusNew, statusShowing fields
    if ($nightID){
	my @new_movies = &tnmc::movies::night::list_new_movies_for_night($nightID);
	if (grep($_ eq $movieID, @new_movies)){
	    $movie->{statusNew} = 1;
	}
	my @showing_movies = &tnmc::movies::night::list_showing_movies_for_night($nightID);
	if (grep($_ eq $movieID, @new_movies)){
	    $movie->{statusShowing} = 1;
	}
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

sub del_movie{
    my ($movieID) = @_;
    my ($sql, $sth, $return);
    
    ###############
    ### Delete the movie
    
    $sql = "DELETE FROM Movies WHERE movieID = '$movieID'";
    my $dbh = &tnmc::db::db_connect();
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    $sth->finish;
}


1;



