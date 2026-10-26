package tnmc::cgi;

use strict;
use warnings;

#
# module configuration
#

#
# module routines
#

sub param {
    my ($key) = @_;

    require CGI;

    if (!defined $key) {
        return &CGI::param();
    }

    # an upload gives the path of its temp file
    my $upload = &CGI::upload($key);
    if ($upload) {
        return &CGI::tmpFileName($upload);
    }

    # always one value: a repeated field gives an array ref, a missing one undef
    my @values = &CGI::multi_param($key);
    return (@values > 1) ? \@values : $values[0];
}

sub cookie {
    my (@args) = @_;

    require CGI;
    return &CGI::cookie(@args);
}

sub redirect {
    my (@args) = @_;

    require CGI;
    return &CGI::redirect(@args);
}

sub url_param {
    my (@args) = @_;

    require CGI;
    return &CGI::url_param(@args);
}

1;
