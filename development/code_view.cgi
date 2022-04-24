#!/usr/bin/perl

#
# Let developers look at the latest code online
#
# Note: this is potentially a HUGE security hole, so we have to
# be _very_ careful about what we let the user do.
#

print "Content-type: text/plain\n\n";

use CGI;
my $cgih = new CGI;
my $file = $cgih->param(file);

if (
    ($file =~ /\.(cgi|pm)$/)          &&    # only .cgi or .pm
    ($file =~ /^[\w\.\/\-]*$/)        &&    # normal chars from begin to end
    ($file !~ /[\;\|\>\<\n\r\`\&\$]/) &&    # no executables (redundant)
    ($file !~ /\.\./)
  )
{    # no ..-ing to a higher directory
    print "   file: $file\n\n";
    print `cat $file`;
}
else {
    print "can't let you look at this file: $file\n";
}

