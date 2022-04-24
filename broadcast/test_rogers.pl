#!/usr/bin/perl

##################################################################
#     Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::broadcast::rogers;

my $message = "this is a test 1";
my $res     = &tnmc::broadcast::rogers::sms_send_rogers('6048891066', $message);
print $res->as_string();
