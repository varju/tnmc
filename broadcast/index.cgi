#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca         
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

use lib '/usr/local/apache/tnmc';
use tnmc;
require 'broadcast/BROADCAST.pl';

	#############
	### Main logic

	&db_connect();
	&header();
	
	print qq{
	      <form action="broadcast_send.cgi" method="post">
	};

	&show_heading("cell phone broadcast centre");
	print qq { 
		<table border="0" cellpadding="0" cellspacing="0" width="350">

		<tr><td colspan="5"><b>Message: (max ~ 160 chars)</b><br>
			<textarea cols=40 rows=5 wrap=virtual name="message"></textarea>
			</td></tr>

		<tr><td colspan="5"><br><b>Recipients:</b>
		<tr>
	};

	
        ### User List of people who have messaging on
        &list_users(\@users, "WHERE phoneTextMail != 'none'", 'ORDER BY username');

	$i = 0;

	foreach $userid (@users){
		&get_user($userid, \%user);
		print qq{
			<td>
			<input type="checkbox" name="user-$userid" value="1">$user{username}
			</td>
		};

		$i++;
		if ($i == 5){
			$i = 0;
			print qq{	</tr><tr>\n};
		}
	}

	print qq{

		</tr>
		<tr><td colspan="5"><br>
			<p>
			<input type="submit" value="Send Message">
			<p>

			<b>Warning:</b><br>
			Phone messaging is unreliable and messages may take
			several hours to arrive, if at all. However 
			delivery time tends to be under 15 minutes most of the time.
			<p>
			If you are broadcasting to a large number of people, it
			may take up to a minute to send to everybody. Please be patient and
			don't do repeat-sends as some people may get several copies of the 
			message.
		</td></tr>
		</table>		
		
		</form>
	}; 
	

	&footer();

