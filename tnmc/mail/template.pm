package tnmc::mail::template;

use strict;
use Mail::Address;

use tnmc::cookie;
use tnmc::db;
use tnmc::mail::prefs;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(messages_print_list message_print messages_print_prefs);
@EXPORT_OK = qw(mail_html_escape);

#
# module vars
#

#
# module routines
#

sub messages_print_list {
    my ($messages_ref) = @_;

    my $from_format = mail_get_pref($USERID,'From');

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

    my $from_format = mail_get_pref($USERID,'From');
    my $AddrFrom = mail_format_from($$msg{AddrFrom},$from_format);
    my $Subject = $$msg{Subject};
    my $Date = $$msg{Date};
    my $Body = $$msg{Body};

    my $delete_url = "delete_message.cgi?Id=$$msg{Id}";

    print "<table>\n";
    print "<tr>\n";
    print "  <td><b>from</b></td>\n";
    print "  <td>", $AddrFrom, "</td>\n";
    print "</tr>\n";

    print "<tr>\n";
    print "  <td><b>subject</b></td>\n";
    print "  <td>", $Subject, "</td>\n";
    print "</tr>\n";

    print "<tr>\n";
    print "  <td><b>date</b></td>\n";
    print "  <td>", $Date, "</td>\n";
    print "</tr>\n";

    print "<tr>\n";
    print "  <td bgcolor='pink'><a href='$delete_url'>delete</a></td>\n";
    print "</tr>\n";

    print "<tr>\n";
    print "  <td colspan=2><pre>", $Body, "</pre></td>\n";
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

sub messages_print_prefs {
    my ($prefs_ref) = @_;

    my %default_prefs;
    my @from_val = ('Both','Name','Addr');
    $default_prefs{From}->{Desc} = "Address Display";
    $default_prefs{From}->{Value} = \@from_val;

    print "<form method=post action='set_prefs.cgi'>\n";

    print "<table>\n";

    foreach my $pref (keys %default_prefs) {
        my $curr_setting = $$prefs_ref{$pref};

        print "<tr>\n";
        print "  <td>", $default_prefs{$pref}->{Desc}, "</td>\n";
        print "  <td>\n";
        print "    <select name='$pref'>\n";
        foreach my $opt (@{$default_prefs{$pref}->{Value}}) {
            my $sel = " selected" if $curr_setting eq $opt;
            print "    <option", $sel, ">", $opt, "\n";
        }
        print "    </select>\n";
        print "  </td>\n";
        print "</tr>\n";
    }

    print "</table>\n";

    print "<input type='image' border=0 src='/template/submit.gif' alt='Submit Changes'>\n";
    print "</form>\n";
}

1;
