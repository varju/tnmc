package tnmc::movies::night;

use strict;

use tnmc::db;

#
# module configuration
#

my $table = "MovieNights";
my $key = "nightID";

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
    if (scalar(@_) == 1){
        ## NEW-STYLE
        # usage: my $night_hash = &get_night($nightID);
        return &tnmc::db::item::getItem($table, $key, $_[0]);
    }
    else{
        ## OLD-STYLE
	
	my ($nightID, $night_ref, $junk) = @_;
	my ($condition);
	
	$condition = "(nightID = '$nightID' OR date = '$nightID')";
	my $dbh = &tnmc::db::db_connect();
	&tnmc::db::db_get_row($night_ref, $dbh, 'MovieNights', $condition);
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

sub list_past_nights{
    my ($factionID) = @_;
    my (@row, $sql, $sth);

    my @night_list;
    
    $sql = "SELECT nightID from MovieNights WHERE date <= NOW() AND factionID = $factionID ORDER BY date DESC, nightID DESC";
    
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

sub update_all_cache_movieIDs{
    
    foreach my $nightID (&list_future_nights()){
        &update_cache_movieIDs($nightID);
    }
}

sub update_cache_movieIDs{
    my ($nightID) = @_;
    
    my $night =  &tnmc::movies::night::get_night($nightID);
    
    # check: don't touch old nights.
    return if ($night->{date} > &tnmc::util::date::now());
    
    ## get movie list
    my @movies = &list_movies_for_night($nightID);
    
    ## save cache to db
    my $cache_movieIDs_string = join (" ", @movies);
    $night->{'cache_movieIDs'} = $cache_movieIDs_string;
    &tnmc::movies::night::set_night(%$night);
    
    return;
}

sub list_movies_for_night{
    my ($nightID) = @_;
    
    my $night =  &tnmc::movies::night::get_night($nightID);
    my @movies = &list_showing_movies_for_night($nightID);
    @movies = grep {! &is_movie_seen_by_faction($night->{'factionID'}, $_)} @movies;
    
    return @movies;
}

sub list_comingsoon_movies_for_night{
    my ($nightID) = @_;

    ### KLUDGE: the logic for this really sucks. 
    ### 
    ### Need to find a way to remove dependency on "statusNew"
    
    my @new_movies;
    &tnmc::movies::show::list_movies(\@new_movies, "WHERE (statusNew)");
    
    my @showing_movies = &list_showing_movies_for_night($nightID);
    
    ## filter: new, not showing;
    my %seen;
    grep($seen{$_}++, @showing_movies);
    my @comingsoon_movies = grep(!$seen{$_}, @new_movies);
    
    return @comingsoon_movies;
}


sub list_new_movies_for_night{
    my ($nightID) = @_;
    
    my $night = &tnmc::movies::night::get_night($nightID);
    
    my @showing_movies = &list_showing_movies_for_night($nightID);
    
    my @past_nights = &list_past_nights($night->{factionID}); ## KLUDGE
    
    my @past_movies0 = &list_cache_movieIDs($past_nights[0]);
    my @past_movies1 = &list_cache_movieIDs($past_nights[1]);
    my @past_movies2 = &list_cache_movieIDs($past_nights[2]);
    
    ## filter: showing, not past;
    my %seen;
    grep($seen{$_}++, (@past_movies0, @past_movies1, @past_movies2));
    my @new_movies = grep(!$seen{$_}, @showing_movies);
    
    return @new_movies;
}

sub list_showing_movies_for_night{
    my ($nightID) = @_;
    
    # get theatres
    my @movies;
    my @theatres = &list_theatres_for_night($nightID);
    
    # get movies
    foreach my $theatreID (@theatres){
	my @movies_t = &tnmc::movies::showtimes::list_movies($theatreID);
	push @movies, @movies_t;
    }
    
    # remove duplicates
    my %seen;
    @movies = grep(!$seen{$_}++, @movies);
    
    return @movies;
}

sub list_theatres_for_night{
    my ($nightID) = @_;
    
    my $night =  &tnmc::movies::night::get_night($nightID);
    my @theatres = split (" ", $night->{valid_theatres});
    
    return @theatres;
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
    
    my $night = &get_night($nightID);
    my @movies = split (" ", $night->{'cache_movieIDs'});
    
    return @movies;
}

1;
