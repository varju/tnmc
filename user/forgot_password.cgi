#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;

#############
### Main logic

&tnmc::db::db_connect();
&tnmc::template::header();

&show_forgot_password();

&tnmc::template::footer();
&tnmc::db::db_disconnect();

##########################################################
#### Sub Procedures
##########################################################

sub show_forgot_password {

    # passwords are hashed, so there is nothing to email
    &tnmc::template::show_heading('I forgot my password');
    print qq{
        <p>
        Forget your password?
        <p>
        Ask an admin to set a new one for you.
        <p>
    };
}

##########################################################
#### The end.
##########################################################
