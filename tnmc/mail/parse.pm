package tnmc::mail::parse;

use strict;

use Mail::Internet;
use Mail::Header;

use tnmc::user;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(message_parse message_lookup_user);
@EXPORT_OK = qw(message_parse_date message_parse_month strip_newline);

#
# module vars
#

#
# module routines
#

sub message_parse {
    my ($raw) = @_;
    my %message;

    my @lines = split(/[\n\r]/,$raw);
    my $in_message = new Mail::Internet \@lines;

    my $header = $in_message->head();
    $message{'AddrTo'} = strip_newline($header->get('To'));
    $message{'AddrFrom'} = strip_newline($header->get('From'));
    $message{'ReplyTo'} = strip_newline($header->get('Reply-To'));
    $message{'Subject'} = strip_newline($header->get('Subject'));
    my $date = strip_newline($header->get('Date'));
    $message{'Date'} = message_parse_date($date);

    $message{'Header'} = $header->as_string();

    $in_message->tidy_body();
    my $body_ref = $in_message->body();
    $message{'Body'} = join("\n",@$body_ref);

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

sub strip_newline {
    my ($str) = @_;
    chomp $str;
    return $str;
}

1;
