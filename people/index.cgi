#!/usr/bin/perl

##################################################################
#    Jeff Steinbok  - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

use lib '/usr/local/apache/tnmc';
use tnmc;

    #############
    ### Main logic

    @users;
    %user;
    

    &header();
    
    &show_heading ("TNMC People");
    
    &show_users();

    &footer();

##########################################################
sub show_users()
{
    my (@users, $userID, %user);

    &list_users(\@users, "WHERE groupDead != '1'", 'ORDER BY username');

    print qq
    {    <table border="0" cellpadding="0" cellspacing="5">
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
    
    foreach $userID (@users)
    {    &get_user($userID, \%user);
        
        print qq
        {    <tr>
            <td nowrap><a href="
                                        javascript:window.open(
                                                'user_view.cgi?userID=$userID',
                                                'ViewUser',
                                                'resizable,height=400,width=450');
                                                index.cgi
                                        ">$user{'username'}</a></td>

            <td></td>
            <td nowrap>$user{'fullname'}</td>
            <td></td>
            <td>$user{"phone$user{phonePrimary}"}</td>
            <td></td>
            <td><a href="mailto:$user{'email'}">$user{'email'}</a></td>
            </tr>
        };
    }

    print qq
    {    </table>
    };
}

##########################################################
#### The end.
##########################################################

