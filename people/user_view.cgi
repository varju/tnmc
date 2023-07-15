#!/usr/bin/perl

##################################################################
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::template;
use tnmc::user;

#############
### Main logic

&tnmc::template::header();

&tnmc::template::show_heading("user detail");

my $userID = &tnmc::cgi::param('userID');

&show_user($userID);

&tnmc::template::footer("userView");

##################################################################
sub show_user {
    my ($userID, $junk) = @_;
    return unless $userID;

    my (@cols, $user, $key, %user);

    @cols = qw (
      username
      fullname
      email
      homepage
      birthdate
      phoneHome
      phoneOffice
      phoneOther
      phoneFido
      phoneTelus
      phoneRogers
      phoneClearnet
      phonePrimary
      phoneTextMail
      address
      blurb
    );

    &tnmc::user::get_user_extended($userID, \%user);

    print qq
    {
            <table>
            };

    foreach $key (@cols) {

        if ($key eq 'userID')   { next; }
        if ($key eq 'password') { next; }

        print qq
        {
                <tr valign=top><td><B>$key</B></td>
                    <td>$user{$key}</td>
                </tr>
                };
    }

    print qq{
            </table>
    };
}

