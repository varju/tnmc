package tnmc::user;

use strict;

#
# module configuration
#
BEGIN
{
    use tnmc::db;
}

#
# module routines
#

sub set_user{
    my (%user, $junk) = @_;
    my ($sql, $sth, $return);
    
    my $dbh = &tnmc::db::db_connect();
    &tnmc::db::db_set_row(\%user, $dbh, 'Personal', 'userID');
    
    ###############
    ### Return the User ID
    
    $sql = "SELECT userID FROM Personal WHERE username = '$user{username}'";
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    ($return) = $sth->fetchrow_array();
    $sth->finish;
    
    return $return;
}

sub del_user{
    my ($userID) = @_;
    my ($sql, $sth);
    
    ###############
    ### Delete the user
    
    my $dbh = &tnmc::db::db_connect();
    $sql = "DELETE FROM Personal WHERE userID = '$userID'";
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    $sth->finish;
}

sub get_user{
    my ($userID, $user_ref) = @_;
    
    my $dbh = &tnmc::db::db_connect();
    my $sql = "SELECT * FROM Personal WHERE userID = ?";
    my $sth = $dbh->prepare($sql)
        or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($userID);
    my $ref = $sth->fetchrow_hashref() || return;
    $sth->finish;
    
    %$user_ref = %$ref;
}

# sub get_user_cache;
{
    my %get_user_cache;
    
sub get_user_cache{
    my ($userID, $user_ref) = @_;
    
    if (!$get_user_cache{$userID}){
        my %hash;
        &get_user($userID, \%hash);
        $get_user_cache{$userID} = \%hash;
    }
    if (defined $user_ref){
        %$user_ref = %{$get_user_cache{$userID}};
    }
    return $get_user_cache{$userID};
}
}

sub get_user_extended{
    my ($userID, $user_ref, $junk) = @_;
    my ($condition);

    my $dbh = &tnmc::db::db_connect();
    $condition = "userID = '$userID'";
    &tnmc::db::db_get_row($user_ref, $dbh, 'Personal', $condition);

    if (!$user_ref->{username}){
        $user_ref->{username} = $user_ref->{fullname};
	$user_ref->{username} =~ s/\W+/_/g;
	$user_ref->{username} = lc($user_ref->{username});
    }
}

sub list_users{
    my ($user_list_ref, $where_clause, $by_clause, $junk) = @_;
    my (@row, $sql, $sth);

    @$user_list_ref = ();

    $sql = "SELECT userID from Personal $where_clause $by_clause";
    my $dbh = &tnmc::db::db_connect();
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    while (@row = $sth->fetchrow_array()){
        push (@$user_list_ref, $row[0]);
    }
    $sth->finish;

    return $#$user_list_ref;
}

sub get_user_list {
    my ($where_clause) = @_;

    my %results;

    my $dbh = &tnmc::db::db_connect();
    my $sql = "SELECT userID,username from Personal $where_clause";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    while (my @row = $sth->fetchrow_array()){
        my $userid = shift(@row);
        my $username = shift(@row);

        $results{$username} = $userid if $username;
    }
    $sth->finish;

    return \%results;
}
    

1;
