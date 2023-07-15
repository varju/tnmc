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

    my @user_fields = sort {
        if ($a eq 'userID') {
            return -4;
        }
        elsif ($b eq 'userID') {
            return 4;
        }
        elsif ($a eq 'username') {
            return -3;
        }
        elsif ($b eq 'username') {
            return 3;
        }
        elsif ($a eq 'fullname') {
            return -2;
        }
        elsif ($b eq 'fullname') {
            return 2;
        }
        else {
            return lc($a) cmp lc($b);
        }
    } keys %user;

    foreach $key (@user_fields) {
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
        foreach $key (@user_fields) {
            my $value = exists($user{$key}) ? $user{$key} : '';
            print "<td>$value</td>";
        }
        print qq{</tr>\n};
    }

    print qq{
        <tr>
        <form method="post" action="admin/user_edit_submit.cgi">
        <td><input type="submit" value="Add:"></td>
    };

    foreach $key (@user_fields) {
        my $value = exists($user{$key}) ? $user{$key} : '';
        my $len = length($value) + 1;
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
