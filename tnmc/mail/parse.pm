package tnmc::mail::parse;

use strict;

use tnmc::user;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(message_parse message_lookup_user);
@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub message_parse {
    my ($raw) = @_;

    my %message;
    my $is_header = 1;

    my @body;
    my @header;
    
    my @lines = split(/[\n\r]/,$raw);
    foreach my $line (@lines) {
        if ($is_header) {
            if ($line =~ /^\s*$/) {
                $is_header = 0;
                next;
            }

            if ($line =~ /^To: (.*)/) {
                $message{'AddrTo'} = $1;
            }
            elsif ($line =~ /^From: (.*)/) {
                $message{'AddrFrom'} = $1;
            }
            elsif ($line =~ /^Date: (.*)/) {
                $message{'Date'} = $1;
            }
            elsif ($line =~ /^Reply-To: (.*)/i) {
                $message{'ReplyTo'} = $1;
            }

            push(@header,$line);
        }
        else {
            push(@body,$line);
        }
    }

    $message{'Body'} .= join("\n",@body);
    $message{'Header'} .= join("\n",@header);

    return \%message;
}

sub message_lookup_user {
    my ($AddrTo) = @_;

    my $users_ref = get_user_list();

    my $attempt;
    if ($AddrTo =~ /(.*)\@/) {
        $attempt = $1;
    }
    else {
        $attempt = $AddrTo;
    }
    
    if (defined $$users_ref{$attempt}) {
        return $$users_ref{$attempt};
    }

    return undef;
}

1;
