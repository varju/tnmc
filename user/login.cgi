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

&tnmc::security::auth::authenticate();


my (%user, %old_user);

my $userID = &tnmc::cgi::param('userID');
my $password = &tnmc::cgi::param('password');
my $location = &tnmc::cgi::param('location');
&get_user($userID, \%user);

### BUG: the old-user stuff doesn't work right now!
my $old_user; #  = $tnmc_cookie_in{'userID'};
#&get_user($old_user, \%old_user);


if (!$location) {
    $location = '/';
}

if ( !$userID 
     || ( ($password ne $user{'password'})
          && ($user{'password'} ne ''))
     )
{
    &header();
    print qq{
        <p>
        <b>Oopsie-daisy!</b>
        <p>
        You entered the wrong password.
        <p>
        If you\'ve forgotten it, you can have your <a href="/user/entry_page.cgi">password emailed to you</a>.
    };
    &footer();

    &tnmc::log::log_login(0,$old_user,$old_user{username},$userID,
                          $user{username},$password);
}
elsif ($userID) {
    
    my $cookie = &tnmc::security::auth::login($userID);
    print &tnmc::cgi::redirect(
			       -uri=>$location,
			       -cookie=>$cookie
			       );

    &tnmc::log::log_login(1,$old_user,$old_user{username},$userID,
                          $user{username},$password);
}
### BUG?: what does this do?
else {
    print &tnmc::cgi::redirect(-uri=>$location);
    &tnmc::log::log_login(0,$old_user,$old_user{username},$userID,
                          $user{username},$password);
}


#### The end.
##########################################################







