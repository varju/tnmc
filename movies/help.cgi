#!/usr/bin/perl
        
##################################################################
#       Scott Thompson - scottt@css.sfu.ca (nov/99)
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
print qq{
	<br>
	Here's the how the database bits map to the movie status:
	<pre><font face="courier">
			seen	showing	new	
	coming soon	0	0	1	
	just released	0	1	1
	showing		0	1	0
	not showing	0	0	0
	seen		1	-	-	
	</font></pre>

};



        &footer();
        &db_disconnect();

#######################################

