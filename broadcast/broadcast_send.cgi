#!/usr/bin/perl

##################################################################
#     Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::broadcast;
use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::user;
use tnmc::cgi;

#############
### Main logic

&db_connect();
&header();

&do_broadcast();

&footer();        
&db_disconnect();

sub do_broadcast{
    
    my $message = &tnmc::cgi::param('message');
    my @params =  &tnmc::cgi::param();
    
    my @userList = ();
    
    foreach $_ (@params){
        if ( /^user-(.*)/) {
            push (@userList, $1);
        }
    }
    
    &smsBroadcast(\@userList, $message);
    
    my $numRec = $#userList + 1;
    print qq{
        <b> $numRec Recipients:</b><br>
        <hr noshade size="1">
    };

    my %user;
    &get_user($USERID, \%user);
    
    open (LOG, '>>broadcast.log');
    print LOG "$user{username} \"$message\" [";
    
    foreach $_ (@userList){
        &get_user($_, \%user);
        print qq{
            $user{username}
        };
        print LOG " $user{username}";
    }
    print LOG " ]\n";
    close LOG;
    print qq{
        <hr noshade size="1">
    };
    
    print qq{ <br><br>
              <b>Message sent:</b><br>
        <hr noshade size="1">
        $message
        <hr noshade size="1">
    };
}

##########################################################
#### The end.
##########################################################

