package tnmc::config;

use strict;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK $tnmc_hostname $tnmc_url $tnmc_email);

@ISA = qw(Exporter);
@EXPORT = qw($tnmc_hostname $tnmc_url $tnmc_email);
@EXPORT_OK = qw();

#
# modules vars
#

$tnmc_hostname = 'tnmc.dhs.org';
$tnmc_url = "http://$tnmc_hostname";
$tnmc_email = 'tnmc-list@interchange.ubc.ca';

1;
