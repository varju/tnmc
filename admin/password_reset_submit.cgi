#!/usr/bin/perl

use strict;
use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::security::reset;
use tnmc::db;
use tnmc::template;
use tnmc::user;
use tnmc::config;
use tnmc::cgi;

#############
### Main logic

&tnmc::db::db_connect();
&tnmc::template::header();

my $userID = &tnmc::cgi::param('userID');
my $user   = $userID ? &tnmc::user::get_user($userID) : undef;

&tnmc::template::show_heading('Password reset link');
if ($user && $user->{userID}) {
    my $token = &tnmc::security::reset::create_token($user->{userID}, 7 * 24);
    print qq{
        <p>
        Send this link to $user->{username}. It works once, for 7 days.
        <p>
        <code>${tnmc_url}user/reset_password.cgi?token=$token</code>
    };
}
else {
    print qq{<p>No such user.\n};
}

&tnmc::template::footer();
&tnmc::db::db_disconnect();
