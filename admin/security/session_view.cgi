#!/usr/bin/perl

##################################################################
#    Scott Thompson 
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::db;
use tnmc::template;
use tnmc::security::session;
use tnmc::security::auth;
use tnmc::user;
use tnmc::util::date;
use tnmc::cgi;

#############
### Main logic

&tnmc::template::header();
&tnmc::db::db_connect();

&tnmc::template::show_heading('Security - View Sessions');

my $userID = &tnmc::cgi::param('userID');
my @sessions;
&tnmc::security::session::list_sessions_for_user($userID, \@sessions);
@sessions = reverse @sessions;
&show_session_list(\@sessions);


&tnmc::template::footer();
&tnmc::db::db_disconnect();

##########################################################
#### sub procedures.
##########################################################

#########################################
sub show_session_list{
    my ($sessions) = @_;
    
    print qq{
        <table cellspacing="0" cellpadding="0" border="0">
        <tr>
            <th>user</td>
            <th>&nbsp;&nbsp;</td>
            <th>o</td>
            <th>&nbsp;&nbsp;</td>
            <th>host</td>
            <th>&nbsp;&nbsp;</td>
            <th>hits</td>
            <th>&nbsp;&nbsp;</td>
            <th>first online</td>
            <th>&nbsp;&nbsp;</td>
            <th>last online</td>
            <th>&nbsp;&nbsp;</td>
            <th></td>
            <th>&nbsp;&nbsp;</td>
        </tr>
    };
    
    foreach my $sessionID (@$sessions){
        my (%session, %user);
        
        &tnmc::security::session::get_session($sessionID, \%session);
        &tnmc::user::get_user($session{'userID'}, \%user);
        
        my $first_online = &tnmc::util::date::format_date('numeric', $session{'firstOnline'});
        my $last_online = &tnmc::util::date::format_date('numeric', $session{'lastOnline'});
        my $host = ($session{'host'}) ? $session{'host'} : $session{'ip'};
        my $font;
        if (! $session{'open'}){
            $font = '<font color="aaaaaa">';
        }
        
        print qq{
            <tr>
                <td nowrap>$font$user{username}</td>
                <td></td>
                <td nowrap>$font$session{'open'}</td>
                <td></td>
                <td nowrap>$font$host</td>
                <td></td>
                <td nowrap>$font$session{'hits'}</td>
                <td></td>
                <td nowrap>$font$first_online</td>
                <td></td>
                <td nowrap>$font$last_online</td>
                <td></td>
                <td nowrap><a href="session_edit.cgi?sessionID=$sessionID">edit</a></td>
            </tr>
        };
        
        
    }
    

    
    print qq{
        </table>
    };

}
