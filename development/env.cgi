#!/usr/bin/perl

use CGI
$cgih = new CGI;

print "Content-type: text/html\n\n";

print <<_HEADER;

    <head>
    <title>TNMC Environment Variables and Form Tester.</title>
    </head>
    
_HEADER


### date stuff.
open (DATE, "/bin/date +%Y%m%d%H |");
while (<DATE>) {
    chomp;
    $today = $_;
}
close (DATE);

print qq{
    <b>Date/Time</b> $today<p>
};

### INClude list
print "<p><b><font color=\"0000ff\">\@INC:</font></b><br>\n";
foreach (@INC)
{    print "$_<br>";
}

### Form Dump
# print "<p><b><font color=\"0000ff\">Standard in / Form Data:</font></b><br> ";
# ### toss url-encoded args from stdin to $a
# read(STDIN, $a, $ENV{CONTENT_LENGTH});
#
#  print "<b>raw dump:</b>$a<p>";


### CGI form data
print "\n<p><b><font color=\"0000ff\">CGI.pm Form Data:</font></b><br>\n";

@names = $cgih->param;
print @names;

print "<p> ";
foreach $name (@names){
    $value = $cgih->param($name);
    print "<b>$name</b> : $value<br>";
}

### Cookies
print "\n<p><b><font color=\"0000ff\">Cookies:</font></b><br>\n";

@cookies = $cgih->cookie();
foreach my $cookie (@cookies){
    print "<b><u>$cookie</u></b><br>";
    my %cookie = $cgih->cookie($cookie);
    print %cookie;
    print "<br>\n";
    foreach $var (sort (keys %cookie)){
        print "<b>$var</b> $cookie{$var}<br>";
    }
    print "<p>";
}
 

### ENV variables
print "<p><b><font color=\"0000ff\">ENV list:</font></b><br> ";
foreach $var (sort (keys %ENV))
{
    print "<b>$var</b> $ENV{$var}<br>";
}

### ENV dump
print "<p><b><font color=\"0000ff\">ENV dump:</font></b><br> ";
print %ENV;


