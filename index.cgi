#!/usr/bin/perl

##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca
#	Jeff Steinbok  - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;

use DBI;
use CGI;

use lib '/usr/local/apache/tnmc';
use tnmc;

use tnmc::templates::bulletins;
use tnmc::templates::movies;
use tnmc::templates::user;

	#############
	### Main logic

	&db_connect();
	&header();

print &greeting($USERID{'fullname'});

show_bulletins();

show_movies();

	&footer();

show_user_homepage();

	&db_disconnect();



##########################################################
#### Sub Procedures
##########################################################

sub greeting
{
	my ($fullname) = @_;
	my ($now, @greetings, $greeting);

	open (DATE, "/bin/date +%H |");
	while (<DATE>) {
	    chop;
	    $now = $_;
	}
	close (DATE);

	### this isn't even remotely tidy; but, hey, it's just for fun!
	{
		@greetings = (
			"Hello",
			"Howdy",
			"G'day",
			"G'day mate",
			"Aloha",
			"Howdy pardner"
			);

		### Before 6 am.
		if ($now < 5)
		{	@greetings = (@greetings,
				"Top o' the morning to you",
				"Good morning"
				);
		}
		### Exactly 6 am.
		if ($now == 6)
		{	@greetings = (
				"Good morning, how's the sunrise today?"
				);
		}
		### from 7 am till noon
		elsif ($now < 12)
		{	@greetings = (@greetings,
				"Good Morning", "Good Morning", "Good Morning"
				);
		}
		### From noon 'till 6 pm
		elsif ($now < 18)
		{	@greetings = (@greetings,
				"Good Afternoon", "Good Afternoon", "Good Afternoon"
				);
		}
		### After 6 pm.
		else 
		{	@greetings = (@greetings, 
				"Good Evening", "Good Evening", "Good Evening"
				);
		}
	}
	
	srand;

	$greeting = @greetings[int(rand ($#greetings + 1) ) ]; 

	return qq{
	        <font style="font-size: 8pt ;"><b>$greeting $fullname.</b><P>
	};


}

##########################################################
#### The end.
##########################################################

