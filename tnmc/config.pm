package tnmc::config;

use strict;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw($tnmc_hostname $tnmc_url);
@EXPORT_OK = qw();

#
# modules vars
#

my $tnmc_hostname = 'tnmc.dhs.org';
my $tnmc_url = "http://$tnmc_hostname:8080";

1;
