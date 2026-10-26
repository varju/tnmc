#!/usr/bin/perl

use strict;
use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::security::reset;
use tnmc::security::session;
use tnmc::db;
use tnmc::template;
use tnmc::user;
use tnmc::cgi;

#############
### Main logic

&tnmc::db::db_connect();
&tnmc::template::header();

my $token     = &tnmc::cgi::param('token');
my $password  = &tnmc::cgi::param('password');
my $password2 = &tnmc::cgi::param('password2');

&tnmc::template::show_heading('Set a new password');

if (!defined $password || length($password) < 8) {
    print qq{<p>Your password needs at least 8 characters. Go back and try again.\n};
}
elsif (!defined $password2 || $password ne $password2) {
    print qq{<p>The two passwords don't match. Go back and try again.\n};
}
elsif (my $userID = &tnmc::security::reset::use_token($token)) {
    my $user = &tnmc::user::get_user($userID);
    $user->{password} = $password;
    &tnmc::user::set_user($user);

    # log out everywhere else
    &tnmc::security::session::close_sessions_for_user($userID);

    print qq{<p>Your password is set. <a href="user/entry_page.cgi">Log in</a>.\n};
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
