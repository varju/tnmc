#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca         
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use CGI;

use strict;
use lib '/usr/local/apache/tnmc';

use tnmc::config;
use tnmc::cookie;
use tnmc::template;
use tnmc::log;

#############
### Main logic

get_cookie();

my $userID = $tnmc_cgi->param('userID');
my $password = $tnmc_cgi->param('password');
my %user;
&get_user($userID, \%user);

my $old_user = $tnmc_cookie_in{'userID'};
my %old_user;
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

my $location = $tnmc_url . '/index.cgi';
if (($password ne $user{'password'})
    && ($user{'password'}))
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

##########################################################
#### The end.
##########################################################

