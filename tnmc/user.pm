##################################################################
#	Scott Thompson (mar 2003)
##################################################################

package tnmc::user;

use strict;
use tnmc;
use tnmc::db;

#
# module configuration
#

my $table = 'Personal';
my $key = 'userID';

#
# module routines
#

sub new_user{
    # usage: my $user_hash = &new_user();
    return &tnmc::db::item::newItem($table, $key);
}

sub add_user{
    # usage: &add_user($user_hash);
    return &tnmc::db::item::addItem($table, $key, $_[0]);
}

sub get_user{
    if (scalar(@_) == 1){
	## NEW-STYLE
	# usage: my $user_hash = &get_user($userID);
	return &tnmc::db::item::getItem($table, $key, $_[0]);
    }
    else{
	## OLD-STYLE
	my ($userID, $user_ref) = @_;
	my $hash =  &tnmc::db::item::getItem($table, $key, $_[0]);
	%$user_ref = %$hash;
    }
}

sub set_user{
    # usage: &set_user($user_hash);
    return &tnmc::db::item::replaceItem($table, $key, $_[0]);
}

sub del_user{
    # usage: &del_user($userID)
    return &tnmc::db::item::delItem($table, $key, $_[0]);
}

sub list_teams{
    # usage: &list_teams("WHERE condition = true ORDER BY column")
    return &tnmc::db::item::listItems($table, $key, $_[0]);
}

#
# old
#



sub old_set_user{
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

sub old_del_user{
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

sub old_get_user{
    
    if (scalar(@_) == 1){
	## NEW-STYLE
	require tnmc::db::item;
	return &tnmc::db::item::getItem('Personal', 'userID', $_[0]);
    }
    else{
	## OLD-STYLE
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

my $by_username_cache;
sub by_username ($$) {
    my ($a, $b) = @_;
    # get user list
    if (! defined $by_username_cache){
	my $hash = &get_user_list();
	
	map {$by_username_cache->{$hash->{$_}} = $_} keys %$hash;
    }
    
    return ($by_username_cache->{$a} cmp $by_username_cache->{$b});
}

1;
