#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca         
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::config;
use tnmc::db;
use tnmc::log;
use tnmc::template;
use tnmc::user;
use tnmc::cgi;

#############
### Main logic

db_connect();
&tnmc::security::auth::authenticate();


my (%user, %old_user);
my $tnmc_cgi = &tnmc::cgi::get_cgih();

my $userID = $tnmc_cgi->param('userID');
my $password = $tnmc_cgi->param('password');
my $location = $tnmc_cgi->param('location');
&get_user($userID, \%user);

### BUG: the old-user stuff doesn't work right now!
my $old_user; #  = $tnmc_cookie_in{'userID'};
#&get_user($old_user, \%old_user);


if (!$location) {
    $location = '/';
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
        <p>
        If you've forgotten it, you can have your <a href="/user/entry_page.cgi">password emailed to you</a>.
    };
    &footer();

    log_login(0,$old_user,$old_user{username},$userID,
              $user{username},$password);
}
elsif ($userID) {
    
    my $cookie = &tnmc::security::auth::login($userID);
    
    print $tnmc_cgi->redirect(
                              -uri=>$location,
                              -cookie=>$cookie
                              );

    log_login(1,$old_user,$old_user{username},$userID,
              $user{username},$password);
}
### BUG?: what does this do?
else {
    print $tnmc_cgi->redirect(-uri=>$location);

    log_login(1,$old_user,$old_user{username},$userID,
              $user{username},$password);
}

db_disconnect();

#### The end.
##########################################################







