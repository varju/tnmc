#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@css.sfu.ca 
#    Jeff Steinbok  - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

use lib '/tnmc';
use tnmc;

require 'basic_testing_tools.pl';

    #############
    ### Main logic
    
    &header();
    &db_connect();

                &show_heading('<a id="personal">Personal</a>');
                &show_edit_users_list();

     &db_disconnect();
    &footer();

##########################################################
#### sub procedures.
##########################################################


#########################################
sub show_edit_users_list{
    my (@users, %user, $userID, $key);

    &list_users(\@users, '', 'ORDER BY username');
    get_user($users[0], \%user);

    print qq{
                <table cellspacing="3" cellpadding="0" border="0">
        <tr>    <td></td>
    };

    foreach $key (keys %user){
        print "<td><b>$key</b></td>";
    }
    print qq{</tr>\n};


        foreach $userID (@users){
                get_user($userID, \%user);
        print qq{
            <tr>
                <td nowrap>
                <a href="user_edit.cgi?userID=$userID">[Edit]</a> 
                <a href="user_delete_submit.cgi?userID=$userID">[Del]</a>
                </td>
        };
        foreach $key (keys %user){
            next unless defined $user{$key};

            print "<td>$user{$key}</td>";
        }
        print qq{</tr>\n};
        }

    print qq{
        <tr>
        <form method="post" action="user_edit_submit.cgi">
        <td><input type="submit" value="Add:"></td>
    };

    foreach $key (keys %user){
        next unless defined $user{$key};

        $len = length($user{$key}) + 1;
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

##########################################################
#### The end.
##########################################################


