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

    print "<form method=post action='set_prefs.cgi'>\n";

    print "<table>\n";

    print "<tr>\n";
    print "  <td>address display</td>\n";
    print "  <td>\n";
    print "    <select name='From'>\n";
    print "      <option value='Name'";
    print " selected" if $$prefs_ref{From} eq 'Name';
    print ">name only\n";
    print "      <option value='Addr'";
    print " selected" if $$prefs_ref{From} eq 'Addr';
    print ">address only\n";
    print "      <option value='Both'";
    print " selected" if $$prefs_ref{From} eq 'Both' || !$$prefs_ref{From};
    print ">both name and address\n";
    print "    </select>\n";
    print "  </td>\n";
    print "</tr>\n";

    print "<tr>\n";
    print "  <td>my address</td>\n";
    print "  <td>\n";
    print "    <select name='FromAddr'>\n";
    print "      <option value='TNMC'";
    print " selected" if $$prefs_ref{FromAddr} eq 'TNMC' || !$$prefs_ref{FromAddr};
    print ">use tnmc address\n";
    print "      <option value='Prefs'";
    print " selected" if $$prefs_ref{FromAddr} eq 'Prefs';
    print ">use value from preferences\n";
    print "    </select>\n";
    print "  </td>\n";
    print "</tr>\n";

    print "</table>\n";

    print "<input type='image' border=0 src='/template/submit.gif' alt='Submit Changes'>\n";
    print "</form>\n";
}

1;
