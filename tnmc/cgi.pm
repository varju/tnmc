package tnmc::cgi;

use strict;
use CGI;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK
            $cgih);

@ISA = qw(Exporter);

@EXPORT = qw();

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub get_cgih{
    
    # reuse handle if possible
    if ($cgih){
        return $cgih;
    }
    
    $cgih = new CGI;
    return $cgih;
}


1;
