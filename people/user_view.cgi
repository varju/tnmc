#!/usr/bin/perl

##################################################################
#	Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

use lib '/usr/local/apache/tnmc';
use tnmc;


	#############
	### Main logic

	&header();

	&show_heading("user detail");

	%user;	
	$cgih = new CGI;
	$userID = $cgih->param('userID');
	
	&show_user($userID);
	
	&footer("userView");


##################################################################
sub show_user
{
	my ($userID, $junk) = @_;	
	my (@cols, $user, $key);
	
	if ($userID)
	{ 
		&db_connect();
		@cols = qw (
			username
			fullname
			email
			homepage
			birthdate
			phoneHome
			phoneOffice
			phoneOther
			phoneFido
			phoneTelus
			phoneRogers
			phoneClearnet
			phonePrimary
			phoneTextMail
			);
	 	# @cols = &db_get_cols_list($dbh_tnmc, 'Personal');
		
			
        	&get_user($userID, \%user);
		&db_disconnect();
	  	
		print qq 
		{
			<table>
		};
	
		foreach $key (@cols){

			if ($key eq 'userID')	{	next;	}
			if ($key eq 'password')	{	next;	}

			print qq 
			{	
				<tr valign=top><td><B>$key</B></td>
				    <td>$user{$key}</td>
				</tr>
			};
        	}
	
		print qq
		{	<input type="submit" value="Submit">
			</table>
			</form>
		}; 
	}
}
	
