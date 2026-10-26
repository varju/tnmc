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

    # pinned, not taken from request headers that clients control
    $tnmc_url             = "https://www.tnmc.ca$tnmc_url_path";
    $tnmc_email           = 'tnmc-list@interchange.ubc.ca';
    $tnmc_basepath        = '/tnmc';
    $tnmc_debug_mode      = 0;
    $tnmc_webserver_email = 'website@tnmc.ca';
}

1;
