package tnmc::movies::show;

use strict;

#
# module configuration
#

BEGIN {
    
    require Exporter;
    require AutoLoader;
    use vars qw(@ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(Exporter AutoLoader);
    
    @EXPORT = qw(show_superfavorite_movie_select show_favorite_movie_select list_movies show_current_nights show_night);
    @EXPORT_OK = qw();
}

1;

__END__

#
# autoloaded module routines
#

sub show_favorite_movie_select{
    use tnmc::db;
    
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
    $sth->finish();

    $sql = "SELECT movieID, title
             FROM Movies
            WHERE statusShowing = '1' AND statusSeen != '1' AND statusBanned != 1
        
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

sub show_superfavorite_movie_select{
    use tnmc::db;
    
    my ($effectiveUserID) = @_;
    my ($sql, $sth, @row, $favoriteMovie, $faveSel);

    print qq{
        <select name="superfavoriteMovie">
        <option value="0">none
        <option value="0">
    };

    $sql = "SELECT movieID
             FROM MovieVotes
            WHERE userID = '$effectiveUserID' AND type = '3'";
    $sth = $dbh_tnmc->prepare($sql);
    $sth->execute;
    ($favoriteMovie) = $sth->fetchrow_array();
    $sth->finish();

    $sql = "SELECT movieID, title
             FROM Movies
            WHERE statusShowing = '1' AND statusSeen != '1' AND statusBanned != 1
        
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
    my $sth = $dbh_tnmc->prepare($sql);
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
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    while (@row = $sth->fetchrow_array()){
        push (@$movie_list_ref, $row[0]);
    }
    $sth->finish;
    
    return $#$movie_list_ref;
}

1;
