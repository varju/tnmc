package tnmc::movies::theatres;

use strict;

use tnmc::db;

#
# module configuration
#

#
# module routines
#

sub get_theatre{
    my ($theatreID) = @_;
    
    # fetch from the db
    my $dbh = &tnmc::db::db_connect();
    my $sql = "SELECT * from MovieTheatres WHERE theatreID = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($theatreID);
    my $hashref = $sth->fetchrow_hashref();
    $sth->finish;
    
    return $hashref;
}

sub get_theatre_by_mybcid{
    my ($mybcid) = @_;
    
    # fetch from the db
    my $dbh = &tnmc::db::db_connect();
    my $sql = "SELECT * from MovieTheatres WHERE mybcid = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($mybcid);
    my $hashref = $sth->fetchrow_hashref();
    $sth->finish;
    
    return $hashref;
}

sub set_theatre{
    my ($hash) = @_;
    
    my @key_list = sort( keys(%$hash) );
    my $key_list = join ( ',', @key_list);
    my $ref_list = join ( ',', (map {sprintf '?'} @key_list) );
    my @var_list = map {$hash->{$_}} @key_list;
    
    # save to the db
    my $dbh = &tnmc::db::db_connect();
    my $sql = "REPLACE INTO MovieTheatres ($key_list) VALUES($ref_list)";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute(@var_list) or return 0;
    
    $sth->finish;
}
sub del_theatre{
    my ($theatreid) = @_;
    
    my $dbh = &tnmc::db::db_connect();
    my $sql = "DELETE from MovieTheatres WHERE theatreID = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($theatreid);
    $sth->finish;
}

sub list_theatres{
    my @list;
    
    # fetch from the db
    my $dbh = &tnmc::db::db_connect();
    my $sql = "SELECT theatreID FROM MovieTheatres ORDER BY name";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute() or return 0;
    while (my @row = $sth->fetchrow_array){
        push @list, $row[0];
    }
    $sth->finish;
    return @list;
}

1;
