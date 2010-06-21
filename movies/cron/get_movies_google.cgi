#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@css.sfu.ca (dec/99)
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::updater::google;

$| = 1;

my $updater = tnmc::updater::google->new();
$updater->update();

1;
