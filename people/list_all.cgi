#!/usr/bin/perl

##################################################################
#	Jeff Steinbok  - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::template;
use tnmc::user;

	#############
	### Main logic

	&header();
	
	&show_heading ("Everybody in the DB");
	
	&show_users();

	&footer();

##########################################################
sub show_users()
{
	my (@users, $userID, %user);

	&list_users(\@users, '', 'ORDER BY fullname');

	print qq
	{	<table border="0" cellpadding="0" cellspacing="5">
		<tr>
		<td><b>UserID</td>
		<td>&nbsp&nbsp</td>
		<td><b>Full Name</td>
		<td>&nbsp&nbsp</td>
		<td><b>Phone Number</td>
		<td>&nbsp&nbsp</td>
		<td><b>E-Mail Address</td>
		</tr>
	};
	
	foreach $userID (@users) {
            &get_user_extended($userID, \%user);
            $user{"phone$user{phonePrimary}"} = '' unless $user{"phone$user{phonePrimary}"};		

            print qq
            {	<tr>
			<td nowrap>$user{'username'}</td>
			<td></td>
			<td nowrap><a href="
                                        javascript:window.open(
                                                'user_view.cgi?userID=$userID',
                                                'ViewUser',
                                                'resizable,height=400,width=450');
                                                index.cgi
                                        ">$user{'fullname'}</a></td>

			<td></td>
			<td>$user{"phone$user{phonePrimary}"}</td>
			<td></td>
			<td><a href="mailto:$user{'email'}">$user{'email'}</a></td>
			</tr>
                        };
	}

	print qq{	</table>
	};
}

##########################################################
#### The end.
##########################################################

