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
    my ($message_ref) = @_;

    my %mail = 
        ( To      => $$message_ref{AddrTo},
          From    => $$message_ref{AddrFrom},
          Subject => $$message_ref{Subject},
          Body    => $$message_ref{Body},
          );

    sendmail(%mail);
}

1;
