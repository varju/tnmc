package tnmc::mail::template;

use strict;
use Mail::Address;

use tnmc::db;
use tnmc::mail::prefs;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(messages_print_list message_print);
@EXPORT_OK = qw(mail_html_escape);

#
# module vars
#

#
# module routines
#

sub messages_print_list {
    my ($messages_ref) = @_;

    my $from_format = mail_get_pref('From');

    print "<table>\n";
    print "<tr>\n";
    print "  <td><b>from</b></td>\n";
    print "  <td><b>subject</b></td>\n";
    print "  <td><b>date</b></td>\n";
    print "</tr>\n";

    foreach my $msg (@$messages_ref) {
        my $url = "view_message.cgi?Id=$$msg{Id}";

        print "<tr>\n";
        print "  <td><a href='$url'>", mail_format_from($$msg{AddrFrom},$from_format), "</a></td>\n";
        print "  <td>", $$msg{Subject}, "</td>\n";
        print "  <td>", $$msg{Date}, "</td>\n";
        print "</tr>\n";
    }

    print "</table>\n";
}

sub message_print {
    my ($msg) = @_;

    print "<table>\n";
    print "<tr>\n";
    print "  <td><b>from</b></td>\n";
    print "  <td>", mail_html_escape($$msg{AddrFrom}), "</td>\n";
    print "</tr>\n";

    print "<tr>\n";
    print "  <td><b>subject</b></td>\n";
    print "  <td>", $$msg{Subject}, "</td>\n";
    print "</tr>\n";

    print "<tr>\n";
    print "  <td><b>date</b></td>\n";
    print "  <td>", $$msg{Date}, "</td>\n";
    print "</tr>\n";

    print "<tr>\n";
    print "  <td colspan=2>&nbsp;</td>\n";
    print "</tr>\n";
    print "<tr>\n";
    print "  <td colspan=2><pre>", $$msg{Body}, "</pre></td>\n";
    print "</tr>\n";

    print "</table>\n";
}

sub mail_html_escape {
    my ($str) = @_;

    $str =~ s/</&lt;/g;
    $str =~ s/>/&gt;/g;
    
    return $str;
}

sub mail_format_from {
    my ($From,$format) = @_;

    my @addrs = Mail::Address->parse($From);
    my $addr = $addrs[0];

    if ($format eq 'Name') {
        return $addr->phrase();
    }
    elsif ($format eq 'Addr') {
        return $addr->address();
    }
    else {
        return $addr->phrase() . ' &lt;' . $addr->address() . '&gt;';
    }
}

1;
