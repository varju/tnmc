#!/usr/bin/perl

##################################################################
#    Jeff Steinbok - steinbok@interchange.ubc.ca
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

my $dbh = &tnmc::db::db_connect();
&tnmc::security::auth::authenticate();

if (&tnmc::cgi::param('username') =~ /\s/)
{
    &tnmc::template::header();
    print "Bad username\n";
    &tnmc::template::footer();
    &tnmc::db::db_disconnect();
    die;
}

my $user = &tnmc::user::new_user();

foreach my $key (keys %$user){
    if (&tnmc::cgi::param($key)){
        $user->{$key} = &tnmc::cgi::param($key);
    }else{
        $user->{$key} = '';
    }
}

# some defaults
$user->{groupMovies} = '1';
$user->{groupPics} = '1';

# for safetey's sake
$user->{groupDev} = '0';
$user->{groupAdmin} = '0';
$user->{userID} = 0;

# add the user
my $userID = &tnmc::user::add_user($user);

&tnmc::template::header();

print qq{
        <form method="post" action="user/login.cgi">
        <input type="hidden" name="userID" value="$userID">
        <input type="hidden" name="password" value="$user->{password}">
        <input type="hidden" name="location" value="user/my_prefs.cgi">

        <b>Account created</b>
        <p>
        <b>$user->{username}  - $user->{fullname}</b>
        <p>
        <input type="submit" value="Continue">
        </form>
        
        };
    
&tnmc::template::footer();

&tnmc::db::db_disconnect();
