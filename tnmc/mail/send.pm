package tnmc::mail::send;

use strict;
use Mail::Sendmail;

use tnmc::db;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(message_send);
@EXPORT_OK = qw();

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
