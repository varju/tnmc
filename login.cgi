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

############################
### Do the date stuff.
my $today;
open (DATE, "/bin/date |");
while (<DATE>) {
    chop;
    $today = $_;
}
close (DATE);

open (LOG, '>>log/login.log');
print LOG "$today\t$ENV{REMOTE_ADDR}\t$ENV{REMOTE_HOST}";
print LOG "\t$old_user\t$old_user{username}\t->\t$userID";
print LOG "\t$user{username}\tpass: $password";

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
    print LOG "\tFAILED";
}
elsif ($userID) {
    print $tnmc_cgi->redirect(
                              -uri=>$location,
                              -cookie=>$tnmc_cookie
                              );
}
else{
    print $tnmc_cgi->redirect(-uri=>$location);
}

print LOG "\n";
close (LOG);

##########################################################
#### The end.
##########################################################

