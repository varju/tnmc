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
#    $cgih = new CGI;
#    print $cgih -> header();

    print "Content-Type: text/html\n\n";
    
        # grab the PubID from the query string
    $query_string = $ENV{QUERY_STRING};
    ($crap, $morecrap) = split (/=/,$query_string);
    
    %description = (
        'fasBookings' => "FAS Room Booking System",
        'fasEvents' => "FAS Events System",
        'csstest' => "CSS Faculty Database",
        'csstestBAK' =>    "Paranoid Scott backing up the CSS faculty database",
          'mysql' => "Internal mySQL information (mysqladmin -u dbmgr -p -h adhara reload)",
        'todo' => "cssweb To do list",
        'mp3' => "Scott and Andrew's mp3 list"
    );
########################################################
### Do the database thing

    #############
    ### connect to the database
        $database = "tnmc";
        $host = "localhost";
        $user = "tnmc";
        $password = "password";
        
        # say hello.
        $dbh = DBI->connect("DBI:mysql:$database:$host", $user, $password) or die "Can't connect: $dbh->errstr\n";


##########################################################
#### The Beginning of the HTML.


$title = "scott's database explorer: $host";
print <<_HTML;
<!----------------------------------- H E A D E R ---------------------------------------->

<title>$title</title>
<body bgcolor="#ffffff">
    
<font face="arial,helvetica" size="+0">

    <font face="arial,helvetica" size="+2"><b>
    $title</b></font>
    <hr noshade>
    <p>
    
    
<table border=0 bgcolor="#003366"><tr><td>
<table border=0 cellpadding=5 cellspacing=1 bgcolor="#ffffff">

<tr><td colspan="2" bgcolor="#003366">
        <div align="center"><font color="white" face="arial,helvetica" size="4">
        <b>$host</b></font></div></td></tr>

<tr><td bgcolor="#cece9c">
        <div align="center"><font color="ffffff" face="arial,helvetica" size="3">
        <b>database</b></font></div></td>
    <td bgcolor="#cece9c">
        <div align="center"><font color="white" face="arial,helvetica" size="3">
        <b>description</b></font></div></td>
        </tr>
_HTML


        $sql="SHOW databases";
        $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
        $sth ->execute or die "Can't execute: $dbh->errstr\n";

        while (@databases = $sth->fetchrow_array){
            foreach $database (@databases){
                print "    <tr><td bgcolor=\"#ffffff\" align=left>";
                print "        <a href=\"database.cgi?$database\"><b>$database</b></a></td>";
                print "        <td>$description{$database}</td></tr>";
            }
        }    
        
        $sth ->finish;
print <<_HTML;

</table>
</td></tr></table>

<p>

<hr noshade>
<font face="arial,helvetica" size="+2"><b>
db tools</b></font><br>


<a href="tools/run.cgi">Execute</a> an SQL command<br>
<a href="tools/bookings-people.cgi">FAS bookings Purple People Making Machine.</a> <br>

<p>
<a href="tools"><i>Directory listing</i></a><br>


<p>
    
<!----------------------------------- D A T A ---------------------------------------->
_HTML






    print "<!----------------------------------- F O O T E R ---------------------------------------->";


    print "</font><hr noshade>";


    #############
    ### Adios
        $dbh ->disconnect;

    print "<div align=\"right\"><i>- database complete</i></div>";


