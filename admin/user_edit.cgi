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

&db_connect();
&header();
my $tnmc_cgi = &tnmc::cgi::get_cgih();

my $userID = $tnmc_cgi->param('userID');

if ($userID)
{ 
    my %user;    
    my @cols = &db_get_cols_list('Personal');
    &get_user($userID, \%user);
    
    print qq 
    {    <form action="user_edit_submit.cgi" method="post">
            <table>
            };
    
    foreach my $key (@cols)
    {       print qq 
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
}

&footer();

&db_disconnect();
