#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca         
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

use lib '/usr/local/apache/tnmc';
use tnmc;
require 'fieldtrip/FIELDTRIP.pl';

	#############
	### Main logic

	&db_connect();
	&header();


	$cgih = new CGI;
	$tripID = $cgih->param(tripID);

#	&get_tripSurvey($tripID, $USERID, \%survey);
#	&show_hash(%survey);
#
#	&get_trip($tripID, \%trip);
#	$trip{title} = 'Long Beach 2000';
#	&set_trip(%trip);

	&show_trip_all($tripID);

	&footer();


#######################################
sub show_trip_all{
	my ($tripID) = @_;
	
	my (%trip);
	&get_trip($tripID, \%trip);


#	####################
#	### userlist
#	$sql = qq{SELECT userID, interest, driving, 
#			 DATE_FORMAT(departDate, '%a %l:%i %p'),
#			 DATE_FORMAT(returnDate, '%a %l:%i %p')
#		    FROM FieldtripSurvey WHERE tripID = '$tripID'};
#	$sth = $dbh_tnmc->prepare($sql);
#	$sth->execute();
#
#	print qq{	<table border="0" cellpadding="1" cellspacing="0">};
#	while (@row = $sth->fetchrow_array()){
#		&get_user(@row[0], \%user);
#		print qq{
#			<tr>	<td>$user{username}</td>
#				<td>$row[1]</td>
#				<td>$row[2]</td>
#				<td> ($row[3] - $row[4])</td>
#				</tr>
#		};
#	}
#	print qq{	</table>};
#
	####################
	### trip entry
#	foreach (keys(%trip)){
#		&show_heading($_);
#		
#		print qq{
#			<table border="0" cellpadding="1" cellspacing="0">
#			<tr><td valign="top">$trip{$_}</td></tr>
#			</table>
#		};
#	}


	&show_heading($trip{title});
		
	print qq{
		<table border="0" cellpadding="1" cellspacing="0">
		<tr><td valign="top">$trip{blurb}</td></tr>
		</table>
	};


}


#######################################
sub show_hash{
	my (%hash) = @_;
	
	&show_heading($hash{title});

	print qq{	<table border="0" cellpadding="1" cellspacing="0">};
	foreach (keys(%hash)){
		print qq{
			<tr><td valign="top"><b>$_</b></td><td>$hash{$_}</td></tr>
		};
	}
	print qq{	</table>};
}


