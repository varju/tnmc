#!/usr/bin/perl

use CGI
$cgih = new CGI;

print "Content-type: text/html\n\n";

print <<_HEADER;

    <head>
    <title>CSSWEB Environment Variables and Form Tester.</title>
    </head>
    
_HEADER

############################
### Do the date stuff.
open (DATE, "/bin/date +%Y%m%d%H |");
while (<DATE>) {
    chomp;
    $today = $_;
}
close (DATE);

print qq{
    <b>Date/Time</b> $today<p>
};


print "<p><b><font color=\"0000ff\">\@INC:</font></b><br>\n";
foreach (@INC)
{    print "$_<br>";
}

#    print "<p><b><font color=\"0000ff\">Standard in / Form Data:</font></b><br> ";
#    ### toss url-encoded args from stdin to $a
#    read(STDIN, $a, $ENV{CONTENT_LENGTH});
#
#    print "<b>raw dump:</b>$a<p>";
#    
#    foreach $_ (split("\&", $a)) 
#    {
#        ### make $name and $value local, split up name=value pairs
#        print "$_<br>";
#        local($name, $value) = split("=", $_);
#    }
#

    print "\n<p><b><font color=\"0000ff\">CGI.pm Form Data:</font></b><br>\n";

    @names = $cgih->param;
    print @names;
    
    print "<p> ";
    foreach $name (@names){
        $value = $cgih->param($name);
        print "<b>$name</b> : $value<br>";
    }
    
print "<p><b><font color=\"0000ff\">ENV list:</font></b><br> ";
foreach $var (sort (keys %ENV))
{
    print "<b>$var</b> $ENV{$var}<br>";
}


print "<p><b><font color=\"0000ff\">ENV dump:</font></b><br> ";
print %ENV;


