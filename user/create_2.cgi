#!/usr/bin/perl

##################################################################
#	Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

use lib '/usr/local/apache/tnmc/';
use tnmc;

        require 'broadcast/BROADCAST.pl';

	#############
	### Main logic
	
	$cgih = new CGI;
	
	&db_connect();
        my %user;
	@cols = &db_get_cols_list($dbh_tnmc, 'Personal');
 	foreach $key (@cols){
	 	if ($cgih->param($key)){
	                $user{$key} = $cgih->param($key);
		}else{
	                $user{$key} = '';
		}
	}
	$user{groupDev} = '0';
        $user{userID} = 0;
	$userID = &set_user(%user);
	
        $sql = "SELECT userID FROM Personal WHERE username = '$user{username}' ORDER BY userID DESC";
        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
        $sth->execute;
	## get the last row
	($userID) = $sth->fetchrow_array();
        $sth->finish;

	smsShout (1, "New User Created: $userID - $user{username} - $user{fullname} - $user{email} - $userID}")


	&header();

# print %user;
	print qq{

		<form method="post" action="/user/login.cgi">
		<input type="hidden" name="userID" value="$userID">
		<input type="hidden" name="password" value="$user{password}">
		<input type="hidden" name="location" value="/user/my_prefs.cgi">

		<b>Account created</b>
		<p>
		<b>$user{username}  - $user{fullname}</b>
		<p>
		<input type="submit" value="Continue">
		</form>
		
	};
	
	&footer();
	
	&db_disconnect();


