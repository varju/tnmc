package tnmc::cgi;

use strict;

#
# module configuration
#

my $cgih;

#
# module routines
#

sub init
{
    if (!defined $cgih)
    {
	require CGI;
	$cgih = new CGI;
    }
}

sub param
{
    my (@args) = @_;

    &init();

    return &CGI::param(@args);
}

sub cookie
{
    my (@args) = @_;

    &init();

    return &CGI::cookie(@args);
}

sub redirect
{
    my (@args) = @_;

    &init();

    return &CGI::redirect(@args);
}

sub url_param
{
    my (@args) = @_;

    &init();

    return &CGI::url_param(@args);
}

1;
