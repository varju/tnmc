package tnmc::security::cookie;

use strict;

#
# module configuration
#
BEGIN {
    
    use vars qw(%cookie);
    
}

#
# module routines
#

# takes sessionID, userID (or looks them up), creates a tnmc-style cookie, returns the string to send to the browser.
sub create_cookie{
    my ($sessionID) = @_;
    
    require tnmc::cgi;
    require tnmc::security::auth;
    
    my $cgih = &tnmc::cgi::get_cgih();
    
    $sessionID ||= &tnmc::security::auth::get_my_sessionID();
    
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
    
    ## cache it if we can
    if (defined %cookie){
        return \%cookie;
    }
    
    ## get all the cookies
    my(@pairs) = split("; ",$ENV{'HTTP_COOKIE'});
    ## find our cookie
    foreach my $line (@pairs) {
        my($key,$value) = split("=", $line);
        next if ($key ne 'TNMC');
        
        # note: this is ugly. it unescapes the keys and vals. i *know* there's a better
        # way to do this, but i'm presently suffering from a massive synaptical failure.
        %cookie = map {($_ =~ s/\%(..)/chr(hex($1))/e) ? $_ : $_}  (split('&',$value));
        
        last;
    }
    
    return \%cookie;
}

1;
