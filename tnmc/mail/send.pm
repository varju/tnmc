package tnmc::mail::send;

use strict;
use warnings;

use Encode;
use MIME::QuotedPrint;
use Net::SMTP;
use POSIX qw(strftime);
use Sys::Hostname;

#
# module configuration
#

# iCloud only sends from addresses on the account, so every message comes from this one
my $smtp_host = 'smtp.mail.me.com';
my $smtp_port = 587;
my $sender    = 'website@tnmc.ca';

# SMTP_USER and SMTP_PASSWORD, mounted by the compose file
my $login_file = '/run/secrets/smtp.env';

#
# module routines
#

sub message_send {
    my ($headers_ref, $body) = @_;

    my %headers = %$headers_ref;

    # keep the display name, and send replies to the original address
    my $from        = $headers{'From'} || '';
    my ($from_name) = $from =~ /^\s*"?([^"<]*?)"?\s*</;
    my ($from_addr) = $from =~ /([^\s<>"]+\@[^\s<>"]+)/;
    if (!$headers{'Reply-To'} && $from_addr && $from_addr !~ /\@tnmc\.ca$/i) {
        $headers{'Reply-To'} = $from_addr;
    }
    $headers{'From'} = ($from_name ? encode_header($from_name) . ' ' : '') . "<$sender>";

    my @recipients;
    foreach my $key ('To', 'Cc', 'Bcc') {
        next if !$headers{$key};
        my @addrs = $headers{$key} =~ /([^\s<>",]+\@[^\s<>",]+)/g;
        push @recipients, @addrs;
    }
    delete $headers{'Bcc'};
    if (!@recipients) {
        warn "tnmc::mail::send: no recipients for '$headers{Subject}'\n";
        return 0;
    }

    $headers{'Subject'} = encode_header($headers{'Subject'} || '');
    $headers{'Date'}       ||= strftime('%a, %d %b %Y %H:%M:%S %z', localtime);
    $headers{'Message-ID'} ||= sprintf('<%d.%d.%d@tnmc.ca>', time, $$, int(rand(1_000_000)));
    $headers{'MIME-Version'}              = '1.0';
    $headers{'Content-Type'}              = 'text/plain; charset="utf-8"';
    $headers{'Content-Transfer-Encoding'} = 'quoted-printable';

    my $message = '';
    foreach my $key (sort keys %headers) {
        $message .= "$key: $headers{$key}\n";
    }
    $message .= "\n" . encode_qp($body);

    my $smtp = Net::SMTP->new($smtp_host, Port => $smtp_port, Hello => hostname(), Timeout => 30);
    if (!$smtp) {
        warn "tnmc::mail::send: can't connect to $smtp_host: $@\n";
        return 0;
    }
    my %login = read_login();
    my $ok =
         $smtp->starttls()
      && $smtp->auth($login{'SMTP_USER'} || '', $login{'SMTP_PASSWORD'} || '')
      && $smtp->mail($sender)
      && $smtp->to(@recipients)
      && $smtp->data($message);
    if (!$ok) {
        warn "tnmc::mail::send: '$headers{Subject}' not sent: " . ($smtp->message() || $@ || 'unknown error') . "\n";
    }
    $smtp->quit();

    return $ok ? 1 : 0;
}

sub read_login {
    my $fh;
    if (!open($fh, '<', $login_file)) {
        warn "tnmc::mail::send: can't read $login_file: $!\n";
        return;
    }
    my %login;
    while (my $line = <$fh>) {
        $login{$1} = $2 if $line =~ /^\s*(\w+)=(.*?)\s*$/;
    }
    close($fh);
    return %login;
}

sub encode_header {
    my ($text) = @_;

    # the database holds UTF-8 bytes
    return $text if $text !~ /[^\x20-\x7e]/;
    return encode('MIME-Q', decode('UTF-8', $text));
}

1;
