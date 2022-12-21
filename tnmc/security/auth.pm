package tnmc::security::auth;

use strict;
use tnmc::security::cookie;
use tnmc::security::session;
use tnmc::user;
use tnmc::util::ip;
use tnmc::cgi;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK
  $USERID $LOGGED_IN $USERID_LAST_KNOWN %USERID);

@ISA = qw(Exporter);

@EXPORT = qw($USERID $LOGGED_IN $USERID_LAST_KNOWN %USERID);

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

### HACK: this code is a bit fuzzy. it needs to be cleaned up after the session db is working

sub authenticate {

    my $sessionID = &get_my_sessionID();
    $USERID            = &get_my_userID();
    $USERID_LAST_KNOWN = &get_my_userID();
    $LOGGED_IN         = &is_open();

    if ($USERID) {
        &tnmc::user::get_user($USERID, \%USERID);
    }
    &tnmc::security::session::hit_session($sessionID);

    if (!&tnmc::security::auth::approve()) {
        print "Content-Type: text/html; charset=utf-8\n\n";
        print "<h1>Access Denied</h1>\n";
        exit("Access Denied $USERID - $USERID{'username'}");
    }
}

sub approve {

    my $path = $ENV{'SCRIPT_NAME'};

    if ($path =~ /^\/admin/ && !$USERID{'groupAdmin'}) {
        return 0;
    }

    if ($path =~ /^\/development/ && !$USERID{'groupDev'}) {
        return 0;
    }

    if ($path =~ /submit/ && !$USERID && $USERID) {
        return 0;
    }
    return 1;
}

sub get_my_sessionID {
    my $cookie = &tnmc::security::cookie::parse_cookie();
    if ($cookie && $cookie->{'sessionID'}) {
        return $cookie->{'sessionID'};
    }
    else {
        return &generate_sessionID();
    }

}

sub generate_sessionID {

    ## assume web connections
    return 'web_' . $ENV{'UNIQUE_ID'};
}

sub get_my_userID {

    my $sessionID = get_my_sessionID();
    my %session;
    &tnmc::security::session::get_session($sessionID, \%session);

    if ($session{'open'}) {
        return $session{'userID'};
    }
    else {
        return 0;
    }
}

sub get_last_userID {

    # stub
    return 0;
}

sub is_open {

    my $sessionID = get_my_sessionID();
    my %session;
    &tnmc::security::session::get_session($sessionID, \%session);

    return $session{'open'};
}

sub login {
    my ($userID) = @_;

    # get a fresh sessionid
    my $sessionID = &generate_sessionID();

    # get the hostname
    my $hostname = &tnmc::util::ip::get_hostname($ENV{'REMOTE_ADDR'});

    # save the session to the db
    my %session = (
        'sessionID'   => $sessionID,
        'userID'      => $userID,
        'firstOnline' => undef(),
        'lastOnline'  => undef(),
        'IP'          => $ENV{'REMOTE_ADDR'},
        'host'        => $hostname,
        'hits'        => 0,
        'open'        => 1,
    );
    &tnmc::security::session::set_session(\%session);

    # send the cookie
    my $cookie_string = &tnmc::security::cookie::create_cookie($sessionID);

    return $cookie_string;

}

sub logout {

    # get the sessionid
    my $sessionID = &get_my_sessionID();
    my $userID    = &get_my_userID();

    &tnmc::security::session::revoke_session($sessionID);

    # send the cookie
    my $cookie_string = &tnmc::security::cookie::create_cookie($sessionID);
    return $cookie_string;

}

BEGIN {
    $USERID    = &get_my_userID();
    $LOGGED_IN = &is_open();
}

1;

