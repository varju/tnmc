#!/usr/bin/perl

##################################################################
#    Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::security::session;

#############
### Main logic

&db_connect();
&header();

my $sessionID = $tnmc_cgi->param('sessionID');

&show_session_admin_edit_form($sessionID);

&footer();

&db_disconnect();

#############
### Subs

sub show_session_admin_edit_form{
    my ($sessionID) = (@_);
    
    return if ! $sessionID;
    
    my %session;
    my @cols = &db_get_cols_list('SessionInfo');
    &tnmc::security::session::get_session($sessionID, \%session);
    
    &show_heading("Edit Session: $sessionID");
    
    print qq 
    {    <form action="session_edit_submit.cgi" method="post">
            <table>
            };
    
    foreach my $key (@cols)
    {       print qq 
            {    
                <tr><td><b>$key</td>
                    <td><input type="text" name="$key" value="$session{$key}"></td>
                </tr>
                };
        }
    
    print qq
    {    </table>
            <input type="submit" value="Submit">
            </form>
            }; 
}
