package tnmc::mail::template;

use strict;
use Mail::Address;

use tnmc::security::auth;
use tnmc::db;
use tnmc::mail::prefs::data;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(messages_print_list message_print message_print_compose);
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
    print "  <td><b>to/from</b></td>\n";
    print "  <td><b>subject</b></td>\n";
    print "  <td><b>date</b></td>\n";
    print "</tr>\n";

    foreach my $msg (@$messages_ref) {
        my $url = "view_message.cgi?Id=$$msg{Id}";

        $$msg{AddrTo} = '' unless $$msg{AddrTo};
        $$msg{AddrFrom} = '' unless $$msg{AddrFrom};
        $$msg{Subject} = '' unless $$msg{Subject};
        $$msg{Date} = '' unless $$msg{Date};

        my $tofrom;
        if ($$msg{Sent}) {
            $tofrom = "to: " . mail_format_from($$msg{AddrTo},$from_format);
        }
        else {
            $tofrom = mail_format_from($$msg{AddrFrom},$from_format);
        }

        print "<tr>\n";
        print "  <td><a href='$url'>", $tofrom, "</a></td>\n";
        print "  <td>", $$msg{Subject}, "</td>\n";
        print "  <td>", $$msg{Date}, "</td>\n";
        print "</tr>\n";
    }

    print "</table>\n";
}

sub message_print {
    my ($msg) = @_;

    my $from_format = mail_get_pref($USERID,'From');
    my $Subject = $$msg{Subject};
    my $Date = $$msg{Date};
    my $Body = $$msg{Body};

    my ($tofrom, $tofrom_label);
    if ($$msg{Sent}) {
        $tofrom_label = "to";
        $tofrom = mail_format_from($$msg{AddrTo},$from_format);
    }
    else {
        $tofrom_label = "from";
        $tofrom = mail_format_from($$msg{AddrFrom},$from_format);
    }

    my $delete_url = "delete_message.cgi?Id=$$msg{Id}";
    my $reply_url = "reply_message.cgi?Id=$$msg{Id}";

    print "<table>\n";
    print "<tr>\n";
    print "  <td><b>", $tofrom_label, "</b></td>\n";
    print "  <td>", $tofrom, "</td>\n";
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
    print "  <td colspan=2>\n";
    print "    <table><tr>\n";
    print "    <td bgcolor='pink'><a href='$delete_url'>delete</a></td>\n";

    if (!$$msg{Sent}) {
        print "    <td bgcolor='pink'><a href='$reply_url'>reply</a></td>\n";
    }

    print "    </tr></table>\n";
    print "  </td>\n";
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

    my $phrase = $addr->phrase();
    my $address = $addr->address();

    if ($format eq 'Name') {
        if ($phrase) {
            return $phrase;
        }
        else {
            return $address;
        }
    }
    elsif ($format eq 'Addr') {
        return $address;
    }
    else {
        if ($phrase) {
            return $phrase . ' &lt;' . $address . '&gt;';
        }
        else {
            return $address;
        }
    }
}

sub message_print_compose {
    my ($message_ref) = @_;

    $$message_ref{AddrFrom} = '' unless $$message_ref{AddrFrom};
    $$message_ref{AddrTo} = '' unless $$message_ref{AddrTo};
    $$message_ref{Subject} = '' unless $$message_ref{Subject};
    $$message_ref{Body} = '' unless $$message_ref{Body};

    print <<EOT;
<form method=post action="send_message.cgi">
<input type=hidden name="AddrFrom" value="$$message_ref{AddrFrom}">

<table>
<tr>
  <td><b>to</b></td>
  <td>
    <input type=text size=30 name="AddrTo" value="$$message_ref{AddrTo}"
  </td>
</tr>

<tr>
  <td><b>subject</b></td>
  <td>
    <input type=text size=30 name="Subject" value="$$message_ref{Subject}"
  </td>
</tr>

<tr>
  <td colspan=2>
    <textarea cols=75 rows=25 wrap=soft name="Body">$$message_ref{Body}</textarea>
  </td>
</tr>
</table>

<input type=submit value="Send">

</form>
EOT

}

1;
