package tnmc::cgi;

use strict;

#
# module configuration
#

BEGIN {
    use vars qw($cgih);
}

#
# module routines
#

sub get_cgih{
    
    # reuse handle if possible
    if (defined $cgih){
        return $cgih;
    }
    
    require CGI;
    
    $cgih = new CGI;
    return $cgih;
}


1;
