#!/usr/bin/perl

##################################################################
#       Scott Thompson - (june/2000)
##################################################################

use lib '/usr/local/apache/tnmc';
use tnmc;
require 'fieldtrip/FIELDTRIP.pl';

	#############
	### Main logic

	&header();

	%trip;
	$cgih = new CGI;
	$tripID = $cgih->param('tripID');
	
 	@cols = &db_get_cols_list($dbh_tnmc, 'Fieldtrips');
       	&get_trip($tripID, \%trip);
  	
	print qq 
	{	<form action="trip_edit_submit.cgi" method="post">
		<table>
	};

	foreach $key (@cols)
       	{       
		print qq 
		{	
			<tr valign=top><td><b>$key</b></td>
		};
	
		if (($key eq 'description')
		   || ($key eq 'blurb'))
		{	print qq {<td><textarea cols="20" rows="5" name="$key">$trip{$key}</textarea></td>};
		}
		else
		{	print qq {<td><input type="text" name="$key" value="$trip{$key}"></td>};
		}
		
		print "</tr>";
       	}

	print qq
	{	</table>
		<input type="submit" value="Submit">
		</form>
	}; 
	

	&footer();
