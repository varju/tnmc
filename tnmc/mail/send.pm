package tnmc::mail::send;

use strict;
use Mail::Sendmail;

#
# module configuration
#

#
# module vars
#

#
# module routines
#

sub message_send {
    my ($headers_ref, $body) = @_;

    my %mail;
    foreach my $key (keys %$headers_ref) {
	$mail{$key} = $$headers_ref{$key};
    }
    $mail{'Body'} = $body;

    sendmail(%mail);
}

1;
