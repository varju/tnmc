package tnmc::security::cookie;

use strict;
use tnmc::security::auth;
use tnmc::cgi;

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
    my ($sessionID) = @_;
    
    my $cgih = &tnmc::cgi::get_cgih();
    
    if (! defined $sessionID){
        $sessionID = &security::auth::get_my_sessionID();
    }
    
    my %cookie = ('sessionID' => $sessionID,
                  );
    
    my $cookie_string = $cgih->cookie(
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
    
    my $cgih = &tnmc::cgi::get_cgih();
    
    %cookie = $cgih->cookie('TNMC');
    
    return \%cookie;
}

1;
