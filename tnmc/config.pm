package tnmc::config;

use strict;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK $tnmc_hostname $tnmc_url $tnmc_email $tnmc_domain);

@ISA = qw(Exporter);
@EXPORT = qw($tnmc_hostname $tnmc_url $tnmc_email $tnmc_domain);
@EXPORT_OK = qw();

#
# modules vars
#

$tnmc_hostname = 'alex.madd.tnmc.ca';
$tnmc_domain = '.tnmc.ca';
$tnmc_url = "http://$tnmc_hostname";
$tnmc_email = 'alex@varju.bc.ca';

1;
