#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@css.sfu.ca (nov/98)
#
#    Based on work by: Gordon Ross - gordonr@cs.sfu.ca (February 05, 1997)
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

########################################################
### Get all the little variables that we'll want to use.
    
        # header and title
    $cgih = new CGI;
    print $cgih -> header();
    
        # grab the PubID from the query string
    $query_string = $ENV{QUERY_STRING};
    ($crap, $morecrap) = split (/=/,$query_string);
    
########################################################
### Do the database thing

    #############
    ### connect to the database
        $database = $query_string;
        $host = "localhost";
        $user = "tnmc";
        $password = "password";
        
        # say hello.
        $dbh = DBI->connect("DBI:mysql:$database:$host", $user, $password) or die "Can't connect: $dbh->errstr\n";


##########################################################
#### The Beginning of the HTML.


$title = "scott's database explorer: $host : $database";

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

<font face="arial, sans-serif" color="#002266">
<h2 align="left">tables in $database</h2>
</font>

<table border=0 bgcolor="#003366"><tr><td>
<table border=0 cellpadding=5 cellspacing=1 bgcolor="#ffffff">
<tr><td colspan=2 bgcolor="#003366">
        <div align="center">
        <font color="white" face="arial,helvetica" size="4"><b>
        $database tables
        </b></font></div></td>

    </tr>
_HTML

    $sql1 ="SHOW TABLES FROM $database";
    $sth1 = $dbh->prepare($sql1) or die "Can't prepare $sql1:$dbh->errstr\n";
    $sth1 ->execute or die "Can't execute: $dbh->errstr\n";
     while (@tables = $sth1->fetchrow_array){
         foreach $table (@tables){
            print "<tr>";
            print "<b><td bgcolor=\"#cece9c\"><div align=\"right\"><a href=\"table.cgi?$database=$table\"><b><font color=\"#000000\">$table</font></a></b></div></td>";
            print "<b><td bgcolor=\"ffffff\"><div align=\"right\"><a href=\"#$table\">column info</a></b></div></td>";
            print "</tr>";
        }
    }
    $sth1 ->finish;
    
print <<_HTML;

</table>
</td></tr></table>


<hr noshade>
<p>

<font face="arial, sans-serif" color="#002266">
<h2 align="left">column info:</h2>
</font>

<table border=0 bgcolor="#003366"><tr><td>
<table border=0 cellpadding=2 cellspacing=1 bgcolor="#ffffff">

<tr><td bgcolor="#002266">
        <div align="center"><font color="ffffff" face="arial,helvetica" size="3">
        <b>column</b></font></div></td>
    <td bgcolor="#002266">
        <div align="center"><font color="white" face="arial,helvetica" size="3">
        <b>data type</b></font></div></td>
    <td bgcolor="#002266">
        <div align="center"><font color="white" face="arial,helvetica" size="3">
        <b>flags</b></font></div></td>
        </tr>


_HTML

    $sql1 ="SHOW TABLES FROM $database";
    $sth1 = $dbh->prepare($sql1) or die "Can't prepare $sql1:$dbh->errstr\n";
    $sth1 ->execute or die "Can't execute: $dbh->errstr\n";
     while (@tables = $sth1->fetchrow_array){
         foreach $table (@tables){
        
            print "<tr><td colspan=\"3\" bgcolor=\"#cece9c\"><div align=\"center\">";
            print "<a name=\"$table\" href=\"table.cgi?$database=$table\">";
            print "<font color=\"000000\" size=\"3\">";
            print "<b>$table</b>";
            print "</font></a></div></td></tr>";

            $sql2="SHOW COLUMNS FROM $table FROM $database";
            $sth2 = $dbh->prepare($sql2) or die "Can't prepare $sql2:$dbh->errstr\n";
            $sth2 ->execute or die "Can't execute: $dbh->errstr\n";
            while (@row2 = $sth2->fetchrow_array){
                print "<tr>";
                print "<td><font size=\"-1\">&nbsp;@row2[0]&nbsp;</font></td>";
                print "<td><font size=\"-1\">&nbsp;@row2[1]&nbsp;</font></td>";
                print "<td><font size=\"-1\">&nbsp;@row2[2]&nbsp;</font></td>";
                print "</tr>";
            }    
            $sth2 ->finish;

        }
    }

    $sth1 ->finish;
        
print <<_HTML;

</table>
</td></tr></table>

<p>
<!----------------------------------- F O O T E R ---------------------------------------->
</font><hr noshade>
</body> </html>

_HTML


#############
### Adios
    $dbh ->disconnect;

print "<div align=\"right\"><i>- database complete</i></div>";

