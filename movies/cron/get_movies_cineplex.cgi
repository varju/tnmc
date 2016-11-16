#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@css.sfu.ca (dec/99)
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::updater::cineplex;

$| = 1;

my $updater = tnmc::updater::cineplex->new();
$updater->update();

1;
