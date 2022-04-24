#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@css.sfu.ca
#    Jeff Steinbok  - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::db;
use tnmc::template;
use tnmc::user;

#############
### Main logic

&tnmc::template::header();
&tnmc::db::db_connect();

&tnmc::template::show_heading('<a id="personal">Personal</a>');
&show_edit_users_list();

&tnmc::db::db_disconnect();
&tnmc::template::footer();

##########################################################
#### sub procedures.
##########################################################

#########################################
sub show_edit_users_list {
    my (@users, %user, $userID, $key);

    &tnmc::user::list_users(\@users, '', 'ORDER BY username');
    &tnmc::user::get_user($users[0], \%user);

    print qq{
                <table cellspacing="3" cellpadding="0" border="0">
        <tr>    <td></td>
    };

    foreach $key (keys %user) {
        print "<td><b>$key</b></td>";
    }
    print qq{</tr>\n};

    foreach $userID (@users) {
        &tnmc::user::get_user($userID, \%user);
        print qq{
            <tr>
                <td nowrap>
                <a href="admin/user_edit.cgi?userID=$userID">[Edit]</a> 
                <a href="admin/user_delete_submit.cgi?userID=$userID">[Del]</a>
                </td>
        };
        foreach $key (keys %user) {
            next unless defined $user{$key};

            print "<td>$user{$key}</td>";
        }
        print qq{</tr>\n};
    }

    print qq{
        <tr>
        <form method="post" action="admin/user_edit_submit.cgi">
        <td><input type="submit" value="Add:"></td>
    };

    foreach $key (keys %user) {
        next unless defined $user{$key};

        my $len = length($user{$key}) + 1;
        print qq{
            <td><input type="text" name="$key" size="$len"></td>
        };
    }

    print qq{
        </form>
        </tr>
    };
    print qq{
                </table>
        };
}
