package task::task;

use strict;

#
# module configuration
#

BEGIN{
    use task::db;
}

#
# module routines
#

sub get_task{
    my ($ID) = @_;
    
    # fetch from the db
    my $sql = "SELECT * from Tasks WHERE ID = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($ID);
    my $hashref = $sth->fetchrow_hashref();
    $sth->finish;
    
    return $hashref;
}

sub set_task{
    my ($hash) = @_;
    
    my @key_list = sort( keys(%$hash) );
    my $key_list = join ( ',', @key_list);
    my $ref_list = join ( ',', (map {sprintf '?'} @key_list) );
    my @var_list = map {$hash->{$_}} @key_list;
    
    # save to the db
    my $sql = "REPLACE INTO Tasks ($key_list) VALUES($ref_list)";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute(@var_list) or return 0;
    
    $sth->finish;
}

sub del_task{
    my ($ID) = @_;
    
    # fetch from the db
    my $sql = "DELETE from Tasks WHERE ID = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($ID);
    $sth->finish;
}

sub list_tasks_for_user{
    my ($userID) = @_;
    
    my @list;
    
    # fetch from the db
    my $sql = "SELECT ID FROM Tasks WHERE userID = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($userID) or return 0;
    while (my @row = $sth->fetchrow_array){
        push @list, $row[0];
    }
    $sth->finish;
    return \@list;
}

1;


