#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/';
use tnmc;
require 'MOVIES.pl';


	#############
	### Main logic

	&db_connect();
	&header();
	
	&show_movieMenu();
	print "<br>";

	&show_heading('Movie Attendance');
	&list_my_attendance($USERID);

	print qq{
		<p>
<b>Poem:</b>
<p>
If you're gone for a long time,<br>
Kidnapped by the orcish hordes.<br>
Then to be all fair and kind,<br>
Your votes will be quite ignored.<br>
<br>
If you're lost for just one week.<br>
(Perchance away on a short trip?<br>
With all your friends from Chesapeake.)<br>
Those votes of yours will just be flipped.<br>
<br>
		
		
		
	};

	&footer();
	&db_disconnect();


