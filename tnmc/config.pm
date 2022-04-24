package tnmc::config;

use strict;

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
    my $method = $ENV{HTTPS} == "on" ? "https" : "http";

    # TODO: Figure out why X-Forwarded-Host isn't being sent through
    # my $http_host = $ENV{HTTP_X_FORWARDED_HOST};
    # my $http_host = $ENV{HTTP_HOST};
    my $http_host = "www.tnmc.ca";

    $tnmc_url             = "$method://$http_host$tnmc_url_path";
    $tnmc_email           = 'tnmc-list@interchange.ubc.ca';
    $tnmc_basepath        = '/tnmc';
    $tnmc_debug_mode      = 0;
    $tnmc_webserver_email = 'website@tnmc.ca';
}

1;
