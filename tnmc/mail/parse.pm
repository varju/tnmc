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
@EXPORT_OK = qw(message_parse_date message_parse_month);

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
    my $date;
    
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
                $date = $1;
            }
            elsif ($line =~ /^Reply-To: (.*)/i) {
                $message{'ReplyTo'} = $1;
            }
            elsif ($line =~ /^Subject: (.*)/i) {
                $message{'Subject'} = $1;
            }

            push(@header,$line);
        }
        else {
            push(@body,$line);
        }
    }

    $message{'Body'} .= join("\n",@body);
    $message{'Header'} .= join("\n",@header);

    $message{'Date'} = message_parse_date($date);

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

sub message_parse_date {
    my ($date) = @_;
    my $timestamp = undef;

    if (!$date) {
        return $timestamp;
    }

    # Thu, 14 Dec 2000 21:21:37 -0800
    if ($date =~ /\w+,\s+(\d+)\s+(\w+)\s+(\d+)\s+(\d+):(\d+):(\d+)/) {
        my $dy = $1;
        my $mo_str = $2;
        my $yr = $3;
        my $hr = $4;
        my $mn = $5;
        my $sc = $6;

        my $mo = message_parse_month($mo_str);
        
        $timestamp = sprintf("%04d%02d%02d%02d%02d%02d",
                             $yr,$mo,$dy,$hr,$mn,$sc);
    }
    else {
        print STDERR "MailDebug: Date $date\n";
    }

    return $timestamp;
}

sub message_parse_month {
    my ($mo_str) = @_;

    if ($mo_str =~ /jan/i) {
        return 1;
    }
    if ($mo_str =~ /feb/i) {
        return 2;
    }
    if ($mo_str =~ /mar/i) {
        return 3;
    }
    if ($mo_str =~ /apr/i) {
        return 4;
    }
    if ($mo_str =~ /may/i) {
        return 5;
    }
    if ($mo_str =~ /jun/i) {
        return 6;
    }
    if ($mo_str =~ /jul/i) {
        return 7;
    }
    if ($mo_str =~ /aug/i) {
        return 8;
    }
    if ($mo_str =~ /sep/i) {
        return 9;
    }
    if ($mo_str =~ /oct/i) {
        return 10;
    }
    if ($mo_str =~ /nov/i) {
        return 11;
    }
    if ($mo_str =~ /dec/i) {
        return 12;
    }

    return 0;
}

1;
