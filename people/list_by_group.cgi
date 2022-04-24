#!/usr/bin/perl

##################################################################
#    Jeff Steinbok  - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::template;
use tnmc::user;

#############
### Main logic

&tnmc::template::header();

my $group  = &tnmc::cgi::param('group');
my $cutoff = &tnmc::cgi::param('cutoff');
my $limit  = &tnmc::cgi::param('limit');

my @users;
&tnmc::user::list_users(\@users, "WHERE group$group >= '$cutoff'", 'ORDER BY username');

&tnmc::template::show_heading("$group People (min: $cutoff)");
&show_user_listing(@users);

&tnmc::template::footer();

#
# subs
#

##########################################################
sub show_user_listing {
    my (@users) = @_;

    my ($userID, %user);

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

    foreach $userID (@users) {
        &tnmc::user::get_user_extended($userID, \%user);

        print qq
        {    <tr>
            <td nowrap><a href="people/user_view.cgi?userID=$userID" target="viewuser">$user{'username'}</a></td>

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

