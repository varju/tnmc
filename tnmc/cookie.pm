package tnmc::cookie;

use strict;
use CGI;

use tnmc::config;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK
            $tnmc_cgi %tnmc_cookie_in $USERID 
            $LOGGED_IN $USERID_LAST_KNOWN %USERID);

@ISA = qw(Exporter);

@EXPORT = qw(get_cookie $tnmc_cgi %tnmc_cookie_in $USERID 
             $LOGGED_IN $USERID_LAST_KNOWN %USERID);

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub get_cookie {
    $tnmc_cgi = new CGI;
    
    %tnmc_cookie_in = $tnmc_cgi->cookie('TNMC');
    if ($tnmc_cookie_in{'logged-in'} eq '1'){
        $USERID = $tnmc_cookie_in{'userID'};
        main::get_user($USERID, \%USERID);
        $ENV{REMOTE_USER} = $USERID{username};
        $LOGGED_IN = $tnmc_cookie_in{'logged-in'};
    }else{
        $USERID_LAST_KNOWN = $tnmc_cookie_in{'userID'};
    }
}

1;
