##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca (nov/98)
#	Jeff Steinbok  - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

require 5.004;
use strict;
use DBI;
use CGI;

require 'db_access.pl';

###################################################################
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

###################################################################
sub del_user{
	my ($userID) = @_;
	my ($sql, $sth, $return);
	
	###############
	### Delete the user
	
	$sql = "DELETE FROM Personal WHERE userID = '$userID'";
	$sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
	$sth->execute;
	$sth->finish;
	
}

###################################################################
sub get_user{
	my ($userID, $user_ref, $junk) = @_;
	my ($condition);

	$condition = "(userID = '$userID' OR username = '$userID')";
	&db_get_row($user_ref, $dbh_tnmc, 'Personal', $condition);
}

###################################################################
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

# Keep perl happy
return 1;
