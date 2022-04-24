#!/usr/bin/perl

##################################################################
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::user;
use tnmc::cgi;

#############
### Main logic

&tnmc::db::db_connect();
&tnmc::template::header();

my @cols = &tnmc::db::db_get_cols_list('Personal');

my $userID = &tnmc::cgi::param('userID');
my %user;
if ($userID) {
    &tnmc::user::get_user($userID, \%user);
}
else {
    $user{userID} = 0;
}

print qq 
{    <form action="admin/user_edit_submit.cgi" method="post">
	 <table>
     };

foreach my $key (@cols) {
    print qq 
    {    
	<tr><td><b>$key</td>
	    <td><input type="text" name="$key" value="$user{$key}"></td>
	    </tr>
	};
}

print qq
{    </table>
            <input type="submit" value="Submit">
            </form>
	};

&tnmc::template::footer();

&tnmc::db::db_disconnect();
