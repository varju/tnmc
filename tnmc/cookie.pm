package tnmc::cookie;

use strict;
use CGI;

use tnmc::config;
use tnmc::user;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK
            $tnmc_cgi %tnmc_cookie_in $USERID 
            $LOGGED_IN $USERID_LAST_KNOWN %USERID);

@ISA = qw(Exporter);

@EXPORT = qw(cookie_get cookie_set cookie_tostring cookie_revoke
             $tnmc_cgi %tnmc_cookie_in $USERID 
             $LOGGED_IN $USERID_LAST_KNOWN %USERID);

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub cookie_get {
    $tnmc_cgi = new CGI;
    
    %tnmc_cookie_in = $tnmc_cgi->cookie('TNMC');
    
    if ($tnmc_cookie_in{'logged-in'} eq '1'){
        $USERID = $tnmc_cookie_in{'userID'};
        get_user($USERID, \%USERID);
        $ENV{REMOTE_USER} = $USERID{username};
    }else{
        $USERID = 0;
        $USERID_LAST_KNOWN = $tnmc_cookie_in{'userID'};
    }

    $LOGGED_IN = $tnmc_cookie_in{'logged-in'};
}

sub cookie_set {
    my ($userID) = @_;

    %tnmc_cookie_in = (
                       'userID' => $userID,
                       'logged-in' => '1'
                       );
}

sub cookie_tostring {
    my $str = $tnmc_cgi->cookie(
                                -name    => 'TNMC',
                                -value   => \%tnmc_cookie_in,
                                -expires => '+1y',
                                -path    => '/',
                                -domain  => $tnmc_hostname,
                                -secure  => '0'
                                );
    
    return $str;
}

sub cookie_revoke {
    $tnmc_cookie_in{'logged-in'} = '0';
}

1;
