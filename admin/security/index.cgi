#!/usr/bin/perl

##################################################################
#    Scott Thompson 
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::db;
use tnmc::template;
use tnmc::user;
use tnmc::util::date;

#############
### Main logic

&tnmc::template::header();
&tnmc::db::db_connect();

&tnmc::template::show_heading('Security');
&show_security_users_list();


&tnmc::template::footer();
&tnmc::db::db_disconnect();

##########################################################
#### sub procedures.
##########################################################

#########################################
sub show_security_users_list{
    my (@users, %user, $userID, $key);

    &tnmc::user::list_users(\@users, '', "ORDER BY username");

    print qq{
        <table cellspacing="0" cellpadding="0" border="0">
        <tr>
            <th>userID</td>
            <th>&nbsp;&nbsp;</td>
            <th>username</td>
            <th>&nbsp;&nbsp;</td>
            <th>sessions</td>
            <th>&nbsp;&nbsp;</td>
            <th>hits</td>
            <th>&nbsp;&nbsp;</td>
            <th>last online</td>
            <th>&nbsp;&nbsp;</td>
            <th>host</td>
        </tr>
    };

    foreach $userID (@users){
        my (@sessions, %user);
        &tnmc::user::get_user($userID, \%user);
        &tnmc::security::session::list_sessions_for_user($userID, \@sessions);

        my $num_sessions = scalar @sessions;
        my ($num_open_sessions, $last_online, $num_hits, $host) = (0,'', 0, '');
        foreach my $sessionID (@sessions){
            my %session;
            &tnmc::security::session::get_session($sessionID, \%session);
            $num_open_sessions ++ if $session{'open'};
            $num_hits += $session{'hits'};
            if ($last_online < $session{'lastOnline'}){
                $last_online = $session{'lastOnline'};
                $host = ($session{'host'}) ? $session{'host'} : $session{'ip'};
            }
        }
        $last_online = &tnmc::util::date::format_date('numeric', $last_online);
        
        print qq{
            <tr>
                <td nowrap>$user{userID}</td>
                <td></td>
                <td nowrap><a href="admin/security/session_view.cgi?userID=$userID">$user{username}</a></td>
                <td></td>
                <td nowrap>$num_open_sessions / $num_sessions</td>
                <td></td>
                <td nowrap>$num_hits</td>
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
