package tnmc::broadcast::util;

use strict;

#
# module configuration
#

#
# module vars
#

#
# module routines
#

sub count_words {
    my ($str) = @_;

    my @words = split(/\w+/, $str);
    my $count = @words;

    return $count;
}

sub phone_get_areacode {
    my ($phone) = @_;
    my $areacode;

    $phone =~ s/\D//g;
    if (length($phone) == 10) {
        $areacode = substr($phone, 0, 3);
    }
    else {
        $areacode = '604';
    }

    return $areacode;
}

sub phone_get_localnum {
    my ($phone) = @_;
    my $localnum;

    $phone =~ s/\D//g;
    if (length($phone) > 7) {
        $localnum = substr($phone, -7, 7);
    }
    else {
        $localnum = $phone;
    }

    return $localnum;
}

1;
