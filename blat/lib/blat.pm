package lib::blat;

use strict;

#
# module configuration
#

BEGIN{
    use lib::db;
}

#
# module routines
#

# db: Games ##########################################################

sub get_next_gameid{
    
    # fetch from the db
    my $sql = "SELECT gameid FROM Games WHERE date >= NOW() ORDER BY date LIMIT 1";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute() or return 0;
    my @row = $sth->fetchrow_array();
    $sth->finish;
    return $row[0];
}

sub get_upcoming_gameids{
    my @list;
    
    # fetch from the db
    my $sql = "SELECT gameid FROM Games WHERE date >= NOW() ORDER BY date LIMIT 3";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute() or return 0;
    while (my @row = $sth->fetchrow_array()){
        push @list, $row[0];
    }
    $sth->finish;
    return @list;
}

sub list_games{
    my @list;
    
    # fetch from the db
    my $sql = "SELECT gameid FROM Games WHERE date > NOW() ORDER BY date";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute() or return 0;
    while (my @row = $sth->fetchrow_array){
        push @list, $row[0];
    }
    $sth->finish;
    return @list;
}
sub get_game{
    my ($gameid) = @_;
    
    # fetch from the db
    my $sql = "SELECT * from Games WHERE gameid = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($gameid);
    my $hashref = $sth->fetchrow_hashref();
    $sth->finish;
    
    return $hashref;
}
sub set_game{
    my ($hash) = @_;
    
    my @key_list = sort( keys(%$hash) );
    my $key_list = join ( ',', @key_list);
    my $ref_list = join ( ',', (map {sprintf '?'} @key_list) );
    my @var_list = map {$hash->{$_}} @key_list;
    
    # save to the db
    my $sql = "REPLACE INTO Games ($key_list) VALUES($ref_list)";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute(@var_list) or return 0;
    
    $sth->finish;
}
sub del_game{
    my ($gameid) = @_;
    
    # Games
    my $sql = "DELETE from Games WHERE gameid = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($gameid);

    # GameAttendance
    $sql = "DELETE from GameAttendance WHERE gameid = ?";
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($gameid);
    $sth->finish;
}
# db: Players ########################################################

sub list_players{
    my @list;
    
    # fetch from the db
    my $sql = "SELECT playerid FROM Players ORDER BY name";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute() or return 0;
    while (my @row = $sth->fetchrow_array){
        push @list, $row[0];
    }
    $sth->finish;
    return @list;
}
sub get_player{
    my ($playerid) = @_;
    
    # fetch from the db
    my $sql = "SELECT * from Players WHERE playerid = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($playerid);
    my $hashref = $sth->fetchrow_hashref();
    $sth->finish;
    
    return $hashref;
}
sub set_player{
    my ($hash) = @_;
    
    my @key_list = sort( keys(%$hash) );
    my $key_list = join ( ',', @key_list);
    my $ref_list = join ( ',', (map {sprintf '?'} @key_list) );
    my @var_list = map {$hash->{$_}} @key_list;
    
    # save to the db
    my $sql = "REPLACE INTO Players ($key_list) VALUES($ref_list)";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute(@var_list) or return 0;
    
    $sth->finish;
}
sub del_player{
    my ($playerid) = @_;
    
    # Players
    my $sql = "DELETE from Players WHERE playerid = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($playerid);

    # GameAttendance
    $sql = "DELETE from GameAttendance WHERE playerid = ?";
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($playerid);
    $sth->finish;
}

# db: GameAttendance #################################################

sub player_is_coming_to_game{
    my ($playerid, $gameid) = @_;
    
    # fetch from the db
    my $sql = "SELECT type from GameAttendance WHERE playerid = ? AND gameid = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($playerid, $gameid);
    my ($val) = $sth->fetchrow_array();
    $sth->finish;
    
    return $val;
    return (rand(24) % 5) <=> 1;
    
}
sub get_attendance{
    my ($playerid, $gameid) = @_;
    
    # fetch from the db
    my $sql = "SELECT * from GameAttendance WHERE playerid = ? AND gameid = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($playerid, $gameid);
    my $hashref = $sth->fetchrow_hashref();
    $sth->finish;
    
    return $hashref;
}
sub set_attendance{
    my ($hash) = @_;
    
    my @key_list = sort( keys(%$hash) );
    my $key_list = join ( ',', @key_list);
    my $ref_list = join ( ',', (map {sprintf '?'} @key_list) );
    my @var_list = map {$hash->{$_}} @key_list;
    
    # save to the db
    my $sql = "REPLACE INTO GameAttendance ($key_list) VALUES($ref_list)";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute(@var_list) or return 0;
    
    $sth->finish;
}

sub del_attendance{
    my ($playerid, $gameid) = @_;
    
    # fetch from the db
    my $sql = "DELETE from GameAttendance WHERE playerid = ? AND gameid = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($playerid, $gameid);
    $sth->finish;
}

sub attendance_names{
    return ('-1' => 'no',
            '0' => '---',
            '' => '---',
            '1' => 'maybe',
            '2' => 'yes');
}

return 1;

