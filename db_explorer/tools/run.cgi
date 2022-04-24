#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@css.sfu.ca (jan/99)
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

$cgih = new CGI;

print $cgih->header();
print '<font face="arial, helvetica" size="-1">';

########################################################
### Get all the little variables that we'll want to use.

$select_database = $cgih->param('database');
$database        = "tnmc";
$host            = "localhost";
$user            = "tnmc";
$password        = "password";

########################################################
### Do the database thing

print <<_HTML;

        <!----------------------------------- H E A D E R ---------------------------------------->


        <title>scott's database tools: sql command results</title>
        <body bgcolor="#ffffff">
    
        <font face="arial,helvetica" size="+2"><b>
        scott's database tools: sql command </b></font>
        <hr noshade>
        <font face="arial, sans-serif">
    
        <form method="POST" action="run-exec.cgi">
    

_HTML

#############
### connect to the database

# say hello.
$dbh = DBI->connect("DBI:mysql:$database:$host", $user, $password);

#############
### Print the form

print qq{    
    <table cellpadding="0" width="100%" cellspacing="0" border="0">
    <tr>
        <td><font face="arial, helvetica" size="-1">
            <b>database</b><br>
            <select name="database">
        };

$sql = "SHOW databases";
$sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
$sth->execute;
while (@row = $sth->fetchrow_array) {
    foreach $db (@row) {
        if ($db eq $select_database) {
            $selected = 'selected';
        }
        else {
            $selected = '';
        }
        print qq{<option $selected value="$db">$db};
    }
}
$sth->finish;

print qq{
    
            </select></font></td>
        <td><font face="arial, helvetica" size="-0">
            <input type="submit" value="Execute"></font></td>
        </tr>
        
    <tr>
        <td><font face="arial, helvetica" size="-1">
            <b>host</b><br>
            <input name="host" value="localhost" size=20></font></td>
        <td><font face="arial, helvetica" size="-1">
            <b>user</b><br>
            <input name="user" value="tnmc" size=20></font></td>
        <td><font face="arial, helvetica" size="-1">
            <b>password</b><br>
            <input type="password" name="password" value="password" size=20></font></td>
        </tr>
    </table>
    
    <p>
    <b>command:</b><br>
    <font face="courier, mono-spaced" >
    <textarea name="sql" cols="80" wrap="virtual" rows="12"></textarea>
    </font><p>
    
     
    
    </form>

};

#############
### Adios

$dbh->disconnect;

print <<_HTML;


<p>
<!----------------------------------- F O O T E R ---------------------------------------->
</font><hr noshade>
</body> </html>

<div align="right"><i>- database complete</i></div>

_HTML

### keepin' perl happy...

