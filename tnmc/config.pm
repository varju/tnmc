package tnmc::config;

use strict;
use warnings;

#
# module configuration
#
BEGIN {
    use Exporter;
    use vars
      qw(@ISA @EXPORT @EXPORT_OK $tnmc_url_path $tnmc_url $tnmc_email $tnmc_basepath $tnmc_debug_mode $tnmc_webserver_email);

    @ISA       = qw(Exporter);
    @EXPORT    = qw($tnmc_url_path $tnmc_url $tnmc_email $tnmc_basepath $tnmc_debug_mode);
    @EXPORT_OK = qw();

    #
    # modules vars
    #

    $tnmc_url_path = "/";

    my $method;
    if (exists($ENV{HTTP_X_FORWARDED_PROTO})) {
        $method = $ENV{HTTP_X_FORWARDED_PROTO};
    }
    else {
        $method = 'http';
    }

    my $http_host;
    if (exists($ENV{HTTP_X_FORWARDED_HOST})) {
        $http_host = $ENV{HTTP_X_FORWARDED_HOST};
    }
    elsif (exists($ENV{HTTP_HOST})) {
        $http_host = $ENV{HTTP_HOST};
    }
    else {
        $http_host = 'www.tnmc.ca';
    }

    $tnmc_url             = "$method://$http_host$tnmc_url_path";
    $tnmc_email           = 'tnmc-list@interchange.ubc.ca';
    $tnmc_basepath        = '/tnmc';
    $tnmc_debug_mode      = 0;
    $tnmc_webserver_email = 'website@tnmc.ca';
}

1;
