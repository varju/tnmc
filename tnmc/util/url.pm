package tnmc::util::url;

use strict;

sub url_encode {
    my ($unencoded) = @_;

    # encode non-alphanumeric non-file characters
    my $encoded = $unencoded;
    $encoded =~ s/([^0-9a-zA-Z\.\_\\\/\:])/sprintf("%%%x", ord($1))/ge;
    return $encoded;
}

1;

