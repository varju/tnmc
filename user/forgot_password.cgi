#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::security::reset;
use tnmc::db;
use tnmc::template;
use tnmc::config;
use tnmc::cgi;
use tnmc::mail::send;

#############
### Main logic

&tnmc::db::db_connect();
&tnmc::template::header();

my $who = &tnmc::cgi::param('who');
if (defined $who && $who ne '') {
    &send_reset_links($who);
    &show_sent();
}
else {
    &show_form();
}

&tnmc::template::footer();
&tnmc::db::db_disconnect();

##########################################################
#### Sub Procedures
##########################################################

sub show_form {
    &tnmc::template::show_heading('I forgot my password');
    print qq{
        <p>
        Enter your username or email address, and we'll email you a link to set a new password.
        <form action="user/forgot_password.cgi" method="post">
            <input type="text" name="who" size="30">
            <input type="submit" value="Email me a link">
        </form>
    };
}

sub show_sent {

    # the same answer whether or not the account exists
    &tnmc::template::show_heading('I forgot my password');
    print qq{
        <p>
        If that matches an account, we've emailed it a link to set a new password.
        The link works once, for 24 hours.
        <p>
        If nothing arrives, ask an admin to make you a link.
    };
}

sub send_reset_links {
    my ($who) = @_;

    my $dbh = &tnmc::db::db_connect();
    my $sql = "SELECT userID, username, email FROM Personal
               WHERE (username = ? OR email = ?) AND email <> '' AND groupDead != '1'";
    my $users = $dbh->selectall_arrayref($sql, { Slice => {} }, $who, $who);

    foreach my $user (@$users) {

        # one email per account every 15 minutes
        next if &tnmc::security::reset::count_recent_tokens($user->{userID}, 15);

        my $token   = &tnmc::security::reset::create_token($user->{userID}, 24);
        my %headers = (
            'To'      => $user->{email},
            'From'    => $tnmc::config::tnmc_webserver_email,
            'Subject' => "[TNMC] Set a new password",
        );
        my $body = sprintf(
"\nHi %s,\n\nTo set a new password for TNMC, open this link within 24 hours:\n\n%suser/reset_password.cgi?token=%s\n\nIf you didn't ask for this, you can ignore this email.\n\n",
            $user->{username}, $tnmc_url, $token);
        &tnmc::mail::send::message_send(\%headers, $body);
    }
}

##########################################################
#### The end.
##########################################################
