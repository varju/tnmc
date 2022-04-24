package task::pics;

use strict;

#
# module configuration
#

BEGIN {
    use task::db;
}

#
# module routines
#

sub set_user {
    my ($hash) = @_;

    my @key_list = sort(keys(%$hash));
    my $key_list = join(',', @key_list);
    my $ref_list = join(',', (map { sprintf '?' } @key_list));
    my @var_list = map { $hash->{$_} } @key_list;

    # save to the db
    my $sql = "REPLACE INTO Users ($key_list) VALUES($ref_list)";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute(@var_list) or return 0;

    $sth->finish;

}

sub del_user {
    my ($userID) = @_;
    my ($sql, $sth);

    $sql = "DELETE FROM Users WHERE userID = '$userID'";
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    $sth->finish;
}

sub get_user {
    my ($ID) = @_;

    # fetch from the db
    my $sql = "SELECT * from Users WHERE UserID = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($ID);
    my $hashref = $sth->fetchrow_hashref();
    $sth->finish;

    return $hashref;
}

sub list_users {
    my ($where_clause, $by_clause, $junk) = @_;
    my (@row, $sql, $sth);

    my @list;

    $sql = "SELECT UserID from Users $where_clause $by_clause";
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    while (@row = $sth->fetchrow_array()) {
        push(@list, $row[0]);
    }
    $sth->finish;

    return @list;
}

sub get_user_list {
    my ($where_clause) = @_;

    my %results;

    my $sql = "SELECT UserID,username from Users $where_clause";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    while (my @row = $sth->fetchrow_array()) {
        my $userid   = shift(@row);
        my $username = shift(@row);

        $results{$username} = $userid if $username;
    }
    $sth->finish;

    return \%results;
}

1;
