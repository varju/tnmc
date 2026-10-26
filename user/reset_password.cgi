#!/usr/bin/perl

use strict;
use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::security::reset;
use tnmc::db;
use tnmc::template;
use tnmc::user;
use tnmc::cgi;

#############
### Main logic

&tnmc::db::db_connect();
&tnmc::template::header();

my $token  = &tnmc::cgi::param('token');
my $userID = &tnmc::security::reset::check_token($token);

&tnmc::template::show_heading('Set a new password');
if ($userID) {
    my $user = &tnmc::user::get_user($userID);
    print qq{
        <form action="user/reset_password_submit.cgi" method="post">
        <input type="hidden" name="token" value="$token">
        <table>
            <tr><td><b>username</b></td><td>$user->{username}</td></tr>
            <tr><td><b>new password</b></td>
                <td><input type="password" name="password" autocomplete="new-password"></td></tr>
            <tr><td><b>again</b></td>
                <td><input type="password" name="password2" autocomplete="new-password"></td></tr>
        </table>
        <input type="submit" value="Set password">
        </form>
    };
}
else {
    print qq{
        <p>
        This link has expired or has already been used.
        <a href="user/forgot_password.cgi">Get a new one</a>.
    };
}

&tnmc::template::footer();
&tnmc::db::db_disconnect();
