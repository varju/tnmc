package tnmc::broadcast::util;

use strict;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);

@EXPORT = qw(count_words);

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub count_words {
    my ($str) = @_;

    my @words = split(/\w+/,$str);
    my $count = @words;

    return $count;
}

1;
