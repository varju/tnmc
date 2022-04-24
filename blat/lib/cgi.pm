package lib::cgi;

use strict;

#
# module configuration
#

BEGIN {
    use Exporter;
    use vars qw(@ISA @EXPORT @EXPORT_OK $cgih);

    @ISA = qw(Exporter);

    @EXPORT = qw($cgih);
}

#
# module routines
#

sub get_cgih {

    # reuse handle if possible
    if (defined $cgih) {
        return $cgih;
    }

    require CGI;

    $cgih = new CGI;
    return $cgih;
}

BEGIN {
    &get_cgih();
}

1;
