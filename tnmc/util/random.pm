package tnmc::util::random;

use strict;
use warnings;

#
# module routines
#

sub bytes {

    # usage: my $bytes = &tnmc::util::random::bytes(16);
    my ($count) = @_;

    open(my $fh, '<', '/dev/urandom')      or die "Can't read /dev/urandom: $!";
    read($fh, my $bytes, $count) == $count or die "Short read from /dev/urandom";
    close($fh);

    return $bytes;
}

sub hex_string {

    # usage: my $token = &tnmc::util::random::hex_string(16);  # 16 bytes, 32 hex digits
    my ($count) = @_;
    return unpack('H*', &bytes($count));
}

1;
