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
use tnmc::user;
use tnmc::util::date;
use CGI;

#############
### Main logic

&header();
&db_connect();

&show_heading('Who\'s online now');
&show_recent_users_list(30, 1);

if ($USERID{'groupAdmin'}){
    print "<p>";
    
    &show_heading('last 24 hrs');
    &show_recent_users_list(1440, undef());
}

&footer();
&db_disconnect();

##########################################################
#### sub procedures.
##########################################################

#########################################
sub show_recent_users_list{
    my ($time, $online) = @_;
    
    my (@sessions);
    &tnmc::security::session::list_recent_sessions($time, $online, \@sessions);
    
    print qq{
        <table cellspacing="0" cellpadding="0" border="0">
        <tr>
            <th>user</td>
            <th>&nbsp;&nbsp;</td>
            <th>last online</td>
            <th>&nbsp;&nbsp;</td>
            <th>from</td>
        </tr>
    };
    
    foreach my $sessionID (@sessions){

        my (%session, %user);
        
        &tnmc::security::session::get_session($sessionID, \%session);
        my $userID = $session{'userID'};
        &get_user($userID, \%user);
        
        my $first_online = &tnmc::util::date::format_date('numeric', $session{'firstOnline'});
        my $last_online = &tnmc::util::date::format_date('numeric', $session{'lastOnline'});
        my $host = ($session{'host'}) ? $session{'host'} : $session{'ip'};
        
        print qq{
            <tr>
                <td nowrap><a href="/people/user_view.cgi?userID=$userID" target="viewuser">$user{username}</a></td>
                <td></td>
                <td nowrap>$last_online</td>
                <td></td>
                <td nowrap>$host</td>
            </tr>
        };
    }
    print qq{
        </table>
    };

}
