#!/usr/bin/perl

##################################################################
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::broadcast;
use tnmc::cookie;
use tnmc::db;
use tnmc::template;
use tnmc::user;

#############
### Main logic

db_connect();
cookie_get();
    
my %user;
my @cols = &db_get_cols_list($dbh_tnmc, 'Personal');

foreach my $key (@cols){
    if ($tnmc_cgi->param($key)){
        $user{$key} = $tnmc_cgi->param($key);
    }else{
        $user{$key} = '';
    }
}
$user{groupDev} = '0';
$user{userID} = 0;
my $userID = &set_user(%user);

my $sql = "SELECT userID FROM Personal WHERE username = '$user{username}' ORDER BY userID DESC";
my $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
$sth->execute;
## get the last row
($userID) = $sth->fetchrow_array();
$sth->finish;

smsShout (1, "New User Created: $userID - $user{username} - $user{fullname} - $user{email} - $userID}")
    
&header();

print qq{
        <form method="post" action="/user/login.cgi">
        <input type="hidden" name="userID" value="$userID">
        <input type="hidden" name="password" value="$user{password}">
        <input type="hidden" name="location" value="/user/my_prefs.cgi">

        <b>Account created</b>
        <p>
        <b>$user{username}  - $user{fullname}</b>
        <p>
        <input type="submit" value="Continue">
        </form>
        
        };
    
&footer();

&db_disconnect();
