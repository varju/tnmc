#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;

require 'pics/PICS.pl';

{
	#############
	### Main logic

	&db_connect();
	&header();

	%pic;	
	$cgih = new CGI;
	$picID = $cgih->param('picID');
	
       	&get_pic($picID, \%pic);
	  	
	print qq {
            
		<form action="pic_edit_admin_submit.cgi" method="post">
		<table>
	};
	
        foreach $key (keys %pic){
       	       print qq{	
			<tr><td><b>$key</td>
                            <td><input type="text" name="$key" value="$pic{$key}"></td>
			</tr>
		};
       	}
	
	print qq{
		</table>
		<input type="submit" value="Submit">
		</form>
	}; 

	
	&footer();

	&db_disconnect();
}
