#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca         
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

use lib '/usr/local/apache/tnmc/';
use tnmc;
require 'fieldtrip/FIELDTRIP.pl';

	#############
	### Main logic

	&db_connect();
	&header();


	$tripID = '1';

	&get_survey($tripID, $USERID, \%survey);
#	&show_hash(%survey);

#	&get_trip($tripID, \%trip);
#	$trip{title} = 'Long Beach 2000';
#	&set_trip(%trip);

	&show_trip($tripID);

	&footer();


#######################################
sub show_trip{
	my ($tripID) = @_;
	
	my (%trip);
	&get_trip($tripID, \%trip);

	if ($USERID == 1){$edit_link = qq{ - <a href="trip_edit.cgi?tripID=$tripID">edit</a>};}
	&show_heading($trip{title} . $edit_link);

	print qq{	<table border="0" cellpadding="1" cellspacing="0">};
		print qq{
			<tr><td colspan="2" valign="top">$trip{blurb}</td></tr>
		};

#	foreach (keys(%trip)){
#		print qq{
#			<tr><td valign="top"><b>$_</b></td><td>$trip{$_}</td></tr>
#		};
#	}
	print qq{	</table>};
}


#######################################
sub show_hash{
	my ($tripID) = @_;
	
	my (%trip);
	&get_trip($tripID, \%trip);

	&show_heading($trip{title});

	print qq{	<table border="0" cellpadding="1" cellspacing="0">};
	foreach (keys(%trip)){
		print qq{
			<tr><td valign="top"><b>$_</b></td><td>$trip{$_}</td></tr>
		};
	}
	print qq{	</table>};
}


