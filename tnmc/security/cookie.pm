package tnmc::security::cookie;

use strict;
use CGI;
use tnmc::security::auth;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK
            );

@ISA = qw(Exporter);

@EXPORT = qw();

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

# takes sessionID, userID (or looks them up), creates a tnmc-style cookie, returns the string to send to the browser.
sub create_cookie{
    my ($sessionID, $userID, $logged_in) = @_;
    
    # to-do: deal with CGI better
    my $tnmc_cgi = new CGI;
    
    if (! defined $sessionID){
        $sessionID = &security::auth::get_my_sessionID();
    }
    
    if (! defined $userID){
        $userID = &security::auth::get_my_userID();
    }

    if (! defined $logged_in){
        $logged_in = &security::auth::is_open;
    }
    
    my %cookie = (
                  'userID' => $userID,
                  'sessionID' => $sessionID,
                  'logged-in' => $logged_in,
                  );
    
    my $cookie_string = $tnmc_cgi->cookie(
                                          -name    => 'TNMC',
                                          -value   => \%cookie,
                                          -expires => '+1y',
                                          -path    => '/',
                                          -secure  => '0'
                                          );
    
    return $cookie_string;
}

# grabs the cookie from the browser, 
sub parse_cookie{
    my %cookie;
    
    # to-do: deal with CGI better;
    my $tnmc_cgi = new CGI;
    
    %cookie = $tnmc_cgi->cookie('TNMC');
    
    return \%cookie;
}

1;
