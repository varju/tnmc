package tnmc::mail::prefs::template;

use strict;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(messages_print_prefs);
@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

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
