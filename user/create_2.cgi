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
    
my %user;
my @cols = &tnmc::db::db_get_cols_list('Personal');

foreach my $key (@cols){
    if (&tnmc::cgi::param($key)){
        $user{$key} = &tnmc::cgi::param($key);
    }else{
        $user{$key} = '';
    }
}

# some defaults
$user{groupMovies} = '1';
$user{groupPics} = '1';

# for safetey's sake
$user{groupDev} = '0';
$user{groupAdmin} = '0';
$user{userID} = 0;

# add the user
my $userID = &tnmc::user::set_user(%user);

my $sql = "SELECT userID FROM Personal WHERE username = '$user{username}' ORDER BY userID DESC";
my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
$sth->execute;
## get the last row
($userID) = $sth->fetchrow_array();
$sth->finish;

&tnmc::broadcast::sms_admin_notify("New User Created: $userID - $user{username} - $user{fullname} - $user{email} - $userID}");
    
&tnmc::template::header();

print qq{
        <form method="post" action="user/login.cgi">
        <input type="hidden" name="userID" value="$userID">
        <input type="hidden" name="password" value="$user{password}">
        <input type="hidden" name="location" value="user/my_prefs.cgi">

        <b>Account created</b>
        <p>
        <b>$user{username}  - $user{fullname}</b>
        <p>
        <input type="submit" value="Continue">
        </form>
        
        };
    
&tnmc::template::footer();

&tnmc::db::db_disconnect();
