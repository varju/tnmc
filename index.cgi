#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
#    Jeff Steinbok  - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';
use tnmc;

#############
### Main logic

&tnmc::template::header();

&tnmc::homepage::greeting::show();
&tnmc::homepage::user::show();
&tnmc::homepage::news::show();
&tnmc::homepage::movies::show();
&tnmc::homepage::message::show();
&tnmc::homepage::teams::show();

&tnmc::template::footer();

# the end.
