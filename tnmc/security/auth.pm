package tnmc::security::auth;

use strict;
use CGI;
use tnmc::security::cookie;
use tnmc::security::session;
use tnmc::user;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK
            $USERID $LOGGED_IN $USERID_LAST_KNOWN %USERID $tnmc_cgi);

@ISA = qw(Exporter);

@EXPORT = qw($USERID $LOGGED_IN $USERID_LAST_KNOWN %USERID $tnmc_cgi);

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

### HACK: this code is a bit fuzzy. it needs to be cleaned up after the session db is working

sub authenticate{
    
    ### HACK: this should be elsewhere. it's in here to make upgrading from cookie.pm easier.
    $tnmc_cgi = new CGI;
    
    my $sessionID = &get_my_sessionID();
    $USERID = &get_my_userID();
    $USERID_LAST_KNOWN = &get_my_userID();
    $LOGGED_IN = &is_open();
    
    if ($USERID){
        &tnmc::user::get_user($USERID, \%USERID);
    }
    
    &tnmc::security::session::hit_session($sessionID);
}

sub get_my_sessionID{
    my $cookie = &tnmc::security::cookie::parse_cookie();
    if ($cookie && $cookie->{'sessionID'}){
        return $cookie->{'sessionID'};
    }
    else{
        return &generate_sessionID();
    }
    
}

sub generate_sessionID{
    
    ## assume web connections
    return 'web_' . $ENV{'UNIQUE_ID'};
}

sub get_my_userID{
    
    ## old style
    my $cookie = &tnmc::security::cookie::parse_cookie();
    if ($cookie->{'logged-in'} eq 1){
        return $cookie->{'userID'};
    }
    else{
        return 0;
    }
    
    ## new style
#    my $sessionID = get_my_sessionID();
#    my $session = &tnmc::security::session::get_session($sessionID);
#    
#    if ($session->{'open'}){
#        return $session->{'userID'};
#    }
#    else{
#        return 0;
#    }
}

sub get_last_userID{
    # stub
    return 0
}

sub is_open{

    ## old style
    my $cookie = &tnmc::security::cookie::parse_cookie();
    return $cookie->{'logged-in'};

    ## new style
#    my $sessionID = get_my_sessionID();
#    my $session;
#    &tnmc::security::session::get_session($sessionID, $session);
#
#    return $session->{'open'};
}

sub login{
    my ($userID) = @_;
    
    # get a fresh sessionid
    my $sessionID = &generate_sessionID();
    
    # save the session to the db
    my %session = ('sessionID' => $sessionID,
                   'userID' => $userID,
                   'firstOnline' => undef(),
                   'lastOnline' => undef(),
                   'IP' => $ENV{'REMOTE_ADDR'},
                   'host' => '',
                   'hits' => 0,
                   'open' => 1,
                   );
    &tnmc::security::session::set_session(\%session);
    
    # send the cookie
    my $cookie_string = &tnmc::security::cookie::create_cookie($sessionID, $userID, 1);
    return $cookie_string;
    
}

sub logout{
    
    # get the sessionid
    my $sessionID = &get_my_sessionID();
    my $userID = &get_my_userID();
    
    &tnmc::security::session::revoke_session($sessionID);
    
    # send the cookie
    my $cookie_string = &tnmc::security::cookie::create_cookie($userID, $sessionID, 0);
    return $cookie_string;
    
}

1;
