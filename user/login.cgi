#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca         
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use CGI;

use strict;
use lib '/usr/local/apache/tnmc';

use tnmc::cookie;
use tnmc::config;
use tnmc::db;
use tnmc::log;
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

%tnmc_cookie_in = (
                   'userID' => $userID,
                   'logged-in' => '1'
                   );

my $tnmc_cookie = $tnmc_cgi->cookie(
                                    -name=>'TNMC',
                                    -value=>\%tnmc_cookie_in,
                                    -expires=>'+1y',
                                    -path=>'/',
                                    -domain=>$tnmc_hostname,
                                    -secure=>'0'
                                    );

if (!$location) {
    $location = $tnmc_url . '/index.cgi';
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
                              -cookie=>$tnmc_cookie
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
