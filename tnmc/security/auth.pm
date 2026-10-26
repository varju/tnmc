package tnmc::security::auth;

use strict;
use warnings;

use tnmc::security::cookie;
use tnmc::security::session;
use tnmc::user;
use tnmc::cgi;
use tnmc::util::random;

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

    if (defined $USERID) {
        &tnmc::user::get_user($USERID, \%USERID);
    }
    &tnmc::security::session::hit_session($sessionID);

    if (!&tnmc::security::auth::approve()) {
        &deny();
    }
}

sub approve {

    my $path = $ENV{'SCRIPT_NAME'};

    # not a web request
    return 1 if !defined $path;

    if ($path =~ /^\/(admin|db\/)/ && !$USERID{'groupAdmin'}) {
        return 0;
    }

    if ($path =~ /^\/development/ && !$USERID{'groupDev'}) {
        return 0;
    }

    # everything else needs a login, except these pages
    my %public = map { $_ => 1 } qw(
      /user/entry_page.cgi
      /user/login.cgi
      /user/logout.cgi
      /user/forgot_password.cgi
    );
    return 1 if $public{$path};

    return $USERID ? 1 : 0;
}

sub deny {
    if (!$USERID) {

        # send visitors to the login page
        require tnmc::config;
        print "Status: 302 Found\n";
        print "Location: ${tnmc::config::tnmc_url}user/entry_page.cgi\n\n";
        exit;
    }

    print "Content-Type: text/html; charset=utf-8\n\n";
    print "<h1>Access Denied</h1>\n";
    exit;
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
    if (!exists($ENV{'GATEWAY_INTERFACE'})) {
        return 'backend';
    }

    ## assume web connections: 128 random bits
    return 'web_' . &tnmc::util::random::hex_string(16);
}

sub get_my_userID {

    my $sessionID = get_my_sessionID();
    my %session;
    &tnmc::security::session::get_active_session($sessionID, \%session);

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
    &tnmc::security::session::get_active_session($sessionID, \%session);

    return $session{'open'};
}

sub login {
    my ($userID) = @_;

    # get a fresh sessionid
    my $sessionID = &generate_sessionID();

    # save the session to the db
    my %session = (
        'sessionID'   => $sessionID,
        'userID'      => $userID,
        'firstOnline' => undef(),
        'lastOnline'  => undef(),
        'IP'          => exists($ENV{'HTTP_X_FORWARDED_FOR'}) ? $ENV{'REMOTE_ADDR'} : $ENV{'REMOTE_ADDR'},
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

    &tnmc::security::session::revoke_session($sessionID);

    # send the cookie
    my $cookie_string = &tnmc::security::cookie::create_cookie($sessionID);
    return $cookie_string;
}

BEGIN {
    $USERID    = &get_my_userID();
    $LOGGED_IN = &is_open();

    # check every web page as it loads, even ones that never call authenticate().
    # tnmc::user may still be loading here, so read the groups straight from the db.
    if (exists $ENV{'GATEWAY_INTERFACE'}) {
        if ($USERID) {
            my $dbh = &tnmc::db::db_connect();
            my $row =
              $dbh->selectrow_hashref("SELECT groupAdmin, groupDev FROM Personal WHERE userID = ?", undef, $USERID);
            %USERID = %$row if $row;
        }
        &deny() if !&approve();
    }
}

1;

