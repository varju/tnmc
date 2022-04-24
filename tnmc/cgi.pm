package tnmc::cgi;

use strict;

#
# module configuration
#

my $cgih;
my $pairs;

#
# module routines
#

sub init {
    if (!defined $cgih) {
        require CGI::Lite;
        $cgih = new CGI::Lite;
        $cgih->set_platform('Unix');
        $pairs = $cgih->parse_form_data();
    }
}

sub param {
    my ($key) = @_;

    &init();

    if (!defined $key) {
        return keys %$pairs;
    }
    else {
        return $$pairs{$key};
    }
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
