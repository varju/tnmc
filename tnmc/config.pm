package tnmc::config;

use strict;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK $tnmc_hostname $tnmc_url $tnmc_email $tnmc_domain $tnmc_maildomain $tnmc_debug_mode);

@ISA = qw(Exporter);
@EXPORT = qw($tnmc_hostname $tnmc_url $tnmc_email $tnmc_domain $tnmc_maildomain $tnmc_debug_mode);
@EXPORT_OK = qw();

#
# modules vars
#

$tnmc_hostname = 'www.tnmc.ca';
$tnmc_domain = '.tnmc.ca';
$tnmc_url = "http://$tnmc_hostname";
$tnmc_email = 'tnmc-list@interchange.ubc.ca';
$tnmc_maildomain = 'tnmc.ca';
$tnmc_debug_mode = 0;

1;
