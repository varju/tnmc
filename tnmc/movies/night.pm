package tnmc::movies::night;

use strict;

#
# module configuration
#
BEGIN {
    
    use tnmc::db;
    
    use Exporter;
    use vars qw(@ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(Exporter);
    @EXPORT = qw(set_night get_night get_next_night list_nights list_future_nights list_active_nights);
    @EXPORT_OK = qw();
    
}

#
# module routines
#

sub set_night{
    my (%night, $junk) = @_;
    my ($sql, $sth, $return);
    
    my $dbh = &tnmc::db::db_connect();
    &tnmc::db::db_set_row(\%night, $dbh, 'MovieNights', 'nightID');
    
    if (!$night{nightID}){
        $sql = "SELECT nightID FROM MovieNights WHERE date = " . $dbh->quote($night{date});
        $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
        $sth->execute;
        ($return) = $sth->fetchrow_array();
        $sth->finish;
    }else{
        $return = $night{nightID};
    }
    return $return;
}

sub get_night{
    my ($nightID, $night_ref, $junk) = @_;
    my ($condition);

    $condition = "(nightID = '$nightID' OR date = '$nightID')";
    my $dbh = &tnmc::db::db_connect();
    &tnmc::db::db_get_row($night_ref, $dbh, 'MovieNights', $condition);
}

# BLOCK: get_next night
{
    my $get_next_night_cache;
sub get_next_night{
    
    ## cache it if we can
    if (defined $get_next_night_cache){
        return $get_next_night_cache;
    }
    
    my ($sql, $sth);
    
    ### BUG ALERT (?)
    
    $sql = "SELECT DATE_FORMAT(date, '%Y%m%d') FROM MovieNights WHERE date >= NOW() ORDER BY date LIMIT 1";
    my $dbh = &tnmc::db::db_connect();
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    ($get_next_night_cache) = $sth->fetchrow_array();
    $sth->finish();
    
    return $get_next_night_cache;
}
}

sub list_nights{
    my ($night_list_ref, $where_clause, $by_clause, $junk) = @_;
    my (@row, $sql, $sth);

    @$night_list_ref = ();

    $sql = "SELECT nightID from MovieNights $where_clause $by_clause";
    my $dbh = &tnmc::db::db_connect();
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    while (@row = $sth->fetchrow_array()){
        push (@$night_list_ref, $row[0]);
    }
    $sth->finish;

    return scalar @$night_list_ref;
}

sub list_future_nights{
    my ($factionID) = @_;
    my (@row, $sql, $sth);
    
    my @night_list = ();
    
    if (defined $factionID){
        $sql = "SELECT nightID from MovieNights WHERE date >= NOW() AND factionID = $factionID ORDER BY date, nightID";
    }
    else{
        $sql = "SELECT nightID from MovieNights WHERE date >= NOW() ORDER BY date, nightID";
    }
    my $dbh = &tnmc::db::db_connect();
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    while (@row = $sth->fetchrow_array()){
        push (@night_list, $row[0]);
    }
    $sth->finish;

    return @night_list;
}

sub list_active_nights{
    my (@row, $sql, $sth);
    
    my @night_list = ();
    
    $sql = "SELECT nightID from MovieNights WHERE date >= NOW() && movieID ORDER BY date, nightID";
    my $dbh = &tnmc::db::db_connect();
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    while (@row = $sth->fetchrow_array()){
        push (@night_list, $row[0]);
    }
    $sth->finish;

    return @night_list;
}

sub list_moviegod_nights{
    my ($userID) = @_;
    
    return if (! int($userID));
    
    my (@row, $sql, $sth);
    
    my @night_list = ();
    
    $sql = "SELECT nightID from MovieNights
             WHERE date >= NOW() and godID = ?
             ORDER BY date, nightID";
    my $dbh = &tnmc::db::db_connect();
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($userID);
    while (@row = $sth->fetchrow_array()){
        push (@night_list, $row[0]);
    }
    $sth->finish;

    return @night_list;
}

sub show_moviegod_links{
    my ($userID) = @_;
    
    use tnmc::user;
    use tnmc::util::date;
    
    # have to be logged in to touch
    return if (!$userID);

    # demo has no access
    return if ($userID == 38);
    
    my %user;
    &tnmc::user::get_user($userID, \%user);
    
    # have to be in group movies to touch
    return if (! $user{groupMovies});
    
    # get moviegod nights
    my @nights = &list_moviegod_nights($userID);
    
    if (scalar @nights){
        print "Be a Movie God:\n";
        foreach my $nightID (@nights){
            my %night;
            &get_night($nightID, \%night);
            print "<a href=\"\/movies\/night_edit.cgi?nightID=$nightID\">", &tnmc::util::date::format_date('short_date', $night{date}), "</a>\n";
            print " - " if ($nightID ne $nights[scalar(@nights) - 1]);
        }
    }
}

sub update_all_cache_movieIDs{
    
    foreach my $nightID (&list_future_nights()){
        &update_cache_movieIDs($nightID);
    }
}

sub update_cache_movieIDs{
    my ($nightID) = @_;
    
    require tnmc::movies::show;
    require tnmc::movies::night;
    require tnmc::util::date;
    
    ## load the night
    my %night;
    &tnmc::movies::night::get_night($nightID, \%night);
    
    return if ($night{date} > &tnmc::util::date::now()); # don't touch old nights.
    ## get all movies
    my @movies;
    &tnmc::movies::show::list_movies(\@movies, "WHERE statusShowing", 'ORDER BY title');
    
    ## TODO: limit the get all movies to only those that are in valid theatres.
    
    ## prune the ones that have been seen
    @movies = grep {! &is_movie_seen_by_faction($night{'factionID'}, $_)} @movies;
    
    ### save cache to db
    my $cache_movieIDs_string = join (" ", @movies);
    $night{'cache_movieIDs'} = $cache_movieIDs_string;
    &tnmc::movies::night::set_night(%night);
    
    return \%night;
}

sub is_movie_seen_by_faction{
    my ($factionID, $movieID) = @_;
    
    my $dbh = &tnmc::db::db_connect();
    
    my $sql = "SELECT nightID from MovieNights
                WHERE factionID = ?
                  AND movieID = ?
                  AND date >= DATE_SUB(NOW(), INTERVAL 1 YEAR)";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($factionID, $movieID);
    my @row = $sth->fetchrow_array();
    $sth->finish;
    
    return $row[0];
}

sub list_cache_movieIDs{
    my ($nightID) = @_;
    my %night;
    &get_night($nightID, \%night);
    my @movie_list = split (" ", $night{'cache_movieIDs'});
    return @movie_list;
}

1;
