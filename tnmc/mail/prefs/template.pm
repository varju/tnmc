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

    # defaults
    if (!defined $$prefs_ref{From}
        || ($$prefs_ref{From} ne 'Name' && $$prefs_ref{From} ne 'Addr')) {
        $$prefs_ref{From} = 'Both';
    }
    if (!defined $$prefs_ref{FromAddr}
        || $$prefs_ref{FromAddr} ne 'Prefs') {
        $$prefs_ref{FromAddr} = 'TNMC';
    }
    if (!defined $$prefs_ref{Quote}
        || $$prefs_ref{Quote} ne 'Yes') {
        $$prefs_ref{Quote} = 'No';
    }
    
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
    print " selected" if $$prefs_ref{From} eq 'Both';
    print ">both name and address\n";
    print "    </select>\n";
    print "  </td>\n";
    print "</tr>\n";

    print "<tr>\n";
    print "  <td>my address</td>\n";
    print "  <td>\n";
    print "    <select name='FromAddr'>\n";
    print "      <option value='TNMC'";
    print " selected" if $$prefs_ref{FromAddr} eq 'TNMC';
    print ">use tnmc address\n";
    print "      <option value='Prefs'";
    print " selected" if $$prefs_ref{FromAddr} eq 'Prefs';
    print ">use value from preferences\n";
    print "    </select>\n";
    print "  </td>\n";
    print "</tr>\n";

    print "<tr>\n";
    print "  <td>quote messages</td>\n";
    print "  <td>\n";
    print "    <select name='Quote'>\n";
    print "      <option value='Yes'";
    print " selected" if $$prefs_ref{Quote} eq 'Yes';
    print ">yes\n";
    print "      <option value='No'";
    print " selected" if $$prefs_ref{Quote} eq 'No';
    print ">no\n";
    print "    </select>\n";
    print "  </td>\n";
    print "</tr>\n";

    print "</table>\n";

    print "<input type='image' border=0 src='/template/submit.gif' alt='Submit Changes'>\n";
    print "</form>\n";
}

1;
