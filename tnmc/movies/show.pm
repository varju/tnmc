package tnmc::movies::show;

use strict;

#
# module configuration
#

BEGIN
{
    require AutoLoader;
    use vars qw(@ISA);
    
    @ISA = qw(AutoLoader);
}

1;

__END__

#
# autoloaded module routines
#

sub show_special_movie_select{
    my ($effectiveUserID, $vote_type, $nightID) = @_;
    
    use tnmc::db;
    require tnmc::movies::night;
    require tnmc::movies::movie;
    
    my %vote_types = ('-1' => 'Anti',
                      '0' => 'Neutral',
                      '1' => 'Normal',
                      '2' => 'Favorite',
                      '3' => 'Super-Favorite',
                      '4' => 'Birthday');
    
    my ($sql, $sth);
    
    print qq{
        <select name="SpecialVote_$vote_type">
        <option value="0">none
        <option value="0">
    };
    
    $sql = "SELECT movieID
             FROM MovieVotes
            WHERE userID = ? AND type = ?";
    my $dbh = &tnmc::db::db_connect();
    $sth = $dbh->prepare($sql);
    $sth->execute($effectiveUserID, $vote_type);
    my ($current_vote) = $sth->fetchrow_array();
    $sth->finish();
    
    my @movie_list = &tnmc::movies::night::list_cache_movieIDs($nightID);
    
    foreach my $movieID (@movie_list){
        my %movie; &tnmc::movies::movie::get_movie($movieID, \%movie);
        
        my $faveSel = ($current_vote == $movieID)? 'selected' : '';
        print qq{               <option value="$movieID" $faveSel>$movie{'title'}\n};
    }
    
    print qq{
        </select>
    };
}

sub show_current_nights{
    
    use tnmc::movies::night;
    
    my @nights = &list_active_nights();
    foreach my $nightID (@nights){
        &show_night($nightID);
    }
    
    return scalar (@nights);
}

sub show_night{
    my ($nightID) = @_;
    
    use tnmc::db;
    use tnmc::movies::movie;
    use tnmc::movies::night;
    
    my %night;
    &get_night($nightID, \%night);
    
    
    my ($current_movie, $current_cinema, $current_showtime, $current_meeting_place, $current_meeting_time, $current_winner_blurb);
    my (%movie);
    
    my $sql = "SELECT DATE_FORMAT('$night{date}', 'W M D, Y')";
    my $dbh = &tnmc::db::db_connect();
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my ($next_tuesday_string) = $sth->fetchrow_array();
    $sth->finish();
    
    $night{'winnerBlurb'} =~ s/\n/<br>/g;
    
    my %movie;
    &get_movie($night{'movieID'}, \%movie);
    
    print qq{
        <TABLE CELLSPACING=0 CELLPADDING=0 width="100">
            <TR>
            <TD colspan="2">$night{'winnerBlurb'}<p><br></TD>
            </TR>
            
            <TR>
            <TD nowrap><B>Movie: </TD>
            <TD nowrap><a href="/movies/movie_view.cgi?movieID=$night{'movieID'}" target="viewmovie">$movie{'title'}</a></TD>
            </TR>
            
            <TR>
            <TD nowrap><B>Cinema: </TD>
            <TD nowrap>$night{'theatre'}</TD>
            </TR>
            
            <TR>
            <TD nowrap><B>Showtime: </TD>
            <TD nowrap>$night{'showtime'}</TD>
            </TR>
            
            <TR>
            <TD nowrap><B>Meeting time: </TD>
            <TD nowrap>$night{'meetingTime'}</TD>
            </TR>
            
            <TR>
            <TD nowrap><B>Meeting place: </TD>
            <TD nowrap>$night{'meetingPlace'}</TD>
            </TR>
            
        </TABLE>
        <P>
    };
}

sub list_movies{
    my ($movie_list_ref, $where_clause, $by_clause, $junk) = @_;
    
    use tnmc::db;
    
    my (@row, $sql, $sth);
    
    @$movie_list_ref = ();
    
    $sql = "SELECT movieID from Movies $where_clause $by_clause";
    my $dbh = &tnmc::db::db_connect();
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    while (@row = $sth->fetchrow_array()){
        push (@$movie_list_ref, $row[0]);
    }
    $sth->finish;
    
    return $#$movie_list_ref;
}

1;
