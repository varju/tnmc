#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@css.sfu.ca (nov/98)
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use warnings;

use DBI;
use CGI;

########################################################
### Get all the little variables that we'll want to use.

# header and title
$cgih = new CGI;
print $cgih->header();

# grab the PubID from the query string
$query_string = $ENV{QUERY_STRING};
($database, $table, $crap) = split(/=/, $query_string);

#    $database = "csstest";
#    $table = "Supervision";

# setting up variables
$host     = "localhost";
$user     = "tnmc";
$password = "password";

########################################################
### Oh, Hello there database.

$dbh = DBI->connect("DBI:mysql:$database:$host", $user, $password) or die "Can't connect: $dbh->errstr\n";

##########################################################
#### The Beginning of the HTML.

$title = "scott's database explorer: $host : $database : $table";

print <<_HTML;
<!----------------------------------- H E A D E R ---------------------------------------->

<title>$title</title>
<body bgcolor="#ffffff">

<font face="arial,helvetica" size="+0">
    <table align="right" border="0"><tr><td><a href="tools/run.cgi?database=$database">run</a></td></tr></table>
    <font face="arial,helvetica" size="+2"><b>
    $title</b></font>
    <hr noshade>
    <p>

<table border=1 cellpadding=2 cellspacing=0 bgcolor="#ffffff">
<tr><th colspan="10" bgcolor="#003366">
        <font size="-2"><br></font>
        <div align="left">
        <font color="white" face="arial,helvetica" size="4"><b><p>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$database - $table&nbsp;&nbsp;&nbsp;&nbsp;<br>
        <font size="-2"><br></font>
        </b></font></div></td>

    </tr>

_HTML

$sql = "SHOW COLUMNS FROM $table FROM $database";
$sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
$sth->execute or die "Can't execute: $dbh->errstr\n";
print "<tr>";
while (@row = $sth->fetchrow_array) {
    print "<td bgcolor=\"#cece9c\"><b>&nbsp;@row[0]&nbsp;</b></td>";

#            print "<b><td bgcolor=\"#cece9c\"><div align=\"right\"><a href=\"table.cgi?$database=$table\"><b><font color=\"#000000\">$table</font></a></b></div></td>";

}
print "</tr>";
$sth->finish;

$sql = "SELECT * FROM $table";
$sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
$sth->execute or die "Can't execute: $dbh->errstr\n";
while (@row = $sth->fetchrow_array) {
    print "<tr>";
    foreach (@row) {
        print "<td bgcolor=\"white\"><font size=\"-1\">$_&nbsp;</font></td>";
    }
    print "</tr>\n";
}
$sth->finish;

print <<_HTML;

</table>

<p>
<!----------------------------------- F O O T E R ---------------------------------------->
</font><hr noshade>
</body> </html>

_HTML

#############
### Adios
$dbh->disconnect;

print "<div align=\"right\"><i>- database complete</i></div>";

# moo
