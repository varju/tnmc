#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::config;
use tnmc::cgi;
use tnmc::user;
use tnmc::mail::send;

# set up the random number generator
srand;

#############
### Main logic

&tnmc::db::db_connect();
&tnmc::template::header();

my $userID = &tnmc::cgi::param('userID');
&show_forgot_password($userID);


&tnmc::template::footer();
&tnmc::db::db_disconnect();



##########################################################
#### Sub Procedures
##########################################################

sub show_forgot_password{
    my ($userID) = @_;
    
    my %user;
    &tnmc::user::get_user($userID, \%user);
    
    if ($user{'email'}){
        &send_password_to_user($userID);
        
        &tnmc::template::show_heading('I forgot my password');
        print qq{
            <p>
            Forget your password?
            <p>
            Tsk tsk $user{'username'}... you really should remember these things. You must be
            getting old and absent minded or something. :\)
            <p>
            Anyhow, your password has been emailed to you at $user{'email'}.
            <p>
        };
    }
    else{
        print qq{
            <p>
            Forget your password?
            <p>
            Sorry, but apparently we can't do anything about it right now. You probably don't have an email address set up.
            <p>
        };
    }
}

sub send_password_to_user{
    my ($userID) = @_;
    
    my %user;
    &tnmc::user::get_user($userID, \%user);
    
    my %message = 
        ( 'AddrTo' => $user{'email'},
          'AddrFrom' => $tnmc::config::tnmc_webserver_email,
          'Subject' => "[TNMC] Forgot your password?",
          'Body' => "\nHi $user{'username'},\n\nYour password for tnmc is \"$user{'password'}\".\n\n",
          );
    &message_send(\%message);
}

##########################################################
#### The end.
##########################################################


