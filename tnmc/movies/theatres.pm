package tnmc::movies::theatres;

use strict;

use tnmc::db;

#
# module configuration
#

my $table = "MovieTheatres";
my $key = "theatreID";

#
# module routines
#

sub get_theatre{
    # usage: my $theatre_hash = &get_theatre($theatreID);
    return &tnmc::db::item::getItem($table, $key, $_[0]);
}

sub get_theatre_by_mybcid{
    my ($mybcid) = @_;
    
    # usage: my $theatre_hash = &get_theatre($theatreID);
    return &tnmc::db::item::getItem($table, "mybcid", $_[0]);
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
    # usage: &list_theatres("WHERE condition = true ORDER BY column")
    my $list =  &tnmc::db::item::listItems($table, $key, $_[0]);
    
    return @$list;
}

1;
