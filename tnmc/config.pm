package tnmc::config;

use strict;

#
# module configuration
#
BEGIN {
    use Exporter;
    use vars qw(@ISA @EXPORT @EXPORT_OK $tnmc_hostname $tnmc_url_path $tnmc_url $tnmc_email $tnmc_domain $tnmc_maildomain $tnmc_basepath $tnmc_debug_mode $tnmc_webserver_email);
    
    @ISA = qw(Exporter);
    @EXPORT = qw($tnmc_hostname $tnmc_url_path $tnmc_url $tnmc_email $tnmc_domain $tnmc_maildomain $tnmc_basepath $tnmc_debug_mode);
    @EXPORT_OK = qw();
    
    
    #
    # modules vars
    #
    
    $tnmc_hostname = 'www.tnmc.ca';
    $tnmc_domain = '.tnmc.ca';
    $tnmc_url_path = "/";
    $tnmc_url = "http://$ENV{HTTP_HOST}$tnmc_url_path";
    $tnmc_email = 'tnmc-list@interchange.ubc.ca';
    $tnmc_maildomain = 'tnmc.ca';
    $tnmc_basepath = '/tnmc';
    $tnmc_debug_mode = 0;
    $tnmc_webserver_email = 'website@tnmc.ca';
}

1;
