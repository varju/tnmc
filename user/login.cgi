#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca         
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use CGI;

use strict;
use lib '/tnmc';

use tnmc::cookie;
use tnmc::config;
use tnmc::db;
use tnmc::log;
use tnmc::template;
use tnmc::user;

#############
### Main logic

db_connect();

cookie_get();

my (%user, %old_user);

my $userID = $tnmc_cgi->param('userID');
my $password = $tnmc_cgi->param('password');
my $location = $tnmc_cgi->param('location');
&get_user($userID, \%user);

my $old_user = $tnmc_cookie_in{'userID'};
&get_user($old_user, \%old_user);

cookie_set($userID);
my $cookie = cookie_tostring();

if (!$location) {
    $location = $tnmc_url . '/';
}

if (($password ne $user{'password'})
    && ($user{'password'} ne ''))
{
    &header();
    print qq{
<p>
<b>Oopsie-daisy!</b>
<p>
You entered the wrong password.
    };
    &footer();

    log_login(0,$old_user,$old_user{username},$userID,
              $user{username},$password);
}
elsif ($userID) {
    print $tnmc_cgi->redirect(
                              -uri=>$location,
                              -cookie=>$cookie
                              );

    log_login(1,$old_user,$old_user{username},$userID,
              $user{username},$password);
}
else {
    print $tnmc_cgi->redirect(-uri=>$location);

    log_login(1,$old_user,$old_user{username},$userID,
              $user{username},$password);
}

db_disconnect();

#### The end.
##########################################################
