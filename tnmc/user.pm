package tnmc::user;

use strict;

use tnmc::config;
use tnmc::db;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(set_user del_user get_user get_user_extended list_users);
@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub set_user{
    my (%user, $junk) = @_;
    my ($sql, $sth, $return);
    
    &db_set_row(\%user, $dbh_tnmc, 'Personal', 'userID');
    
    ###############
    ### Return the User ID
    
    $sql = "SELECT userID FROM Personal WHERE username = '$user{username}'";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
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
    
    $sql = "DELETE FROM Personal WHERE userID = '$userID'";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    $sth->finish;
}

sub get_user{
    my ($userID, $user_ref, $junk) = @_;
    my ($condition);

    $condition = "userID = '$userID'";
    &db_get_row($user_ref, $dbh_tnmc, 'Personal', $condition);
}

sub get_user_extended{
    my ($userID, $user_ref, $junk) = @_;
    my ($condition);

    $condition = "userID = '$userID'";
    &db_get_row($user_ref, $dbh_tnmc, 'Personal', $condition);

    if (!$user_ref->{username}){
        $user_ref->{username} = $user_ref->{fullname};
	$user_ref->{username} =~ s/\W+//g;
    }
}

sub list_users{
    my ($user_list_ref, $where_clause, $by_clause, $junk) = @_;
    my (@row, $sql, $sth);

    @$user_list_ref = ();

    $sql = "SELECT userID from Personal $where_clause $by_clause";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    while (@row = $sth->fetchrow_array()){
        push (@$user_list_ref, $row[0]);
    }
    $sth->finish;

    return $#$user_list_ref;
}

1;
