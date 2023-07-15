#!/usr/local/bin/perl

##################################################################
#    Scott Thompson - scottt@css.sfu.ca (jan/99)
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use warnings;

use DBI;
use CGI;

$cgih = new CGI;

print $cgih->header();
print '<font face="arial, helvetica" size="-1">';

########################################################
### Get all the little variables that we'll want to use.

$database = "fasBookings";
$host     = "adhara";
$user     = "fasBookings";
$password = "quack";

########################################################
### Do the database thing

print <<_HTML;

        <!----------------------------------- H E A D E R ---------------------------------------->


        <title>scott's database tools: the fas bookings purple people adder</title>
        <body bgcolor="#eeccff">

        <font face="arial,helvetica" size="+2"><b>
        scott's database tools:<br> the fas bookings purple people making machine </b></font>
        <hr noshade>
        <font face="arial, sans-serif">

        <form method="POST" action="bookings-people-exec.cgi">


_HTML

#############
### connect to the database

# say hello.
$dbh = DBI->connect("DBI:mysql:$database:$host", $user, $password);

#############
### Print the form

print qq{
    <table cellpadding="0"  cellspacing="5" border="0">
    <tr>
        <td><font face="arial, helvetica" size="-1">
            <b>Email</b><br>
            <select name="email">
            <option>
        };

$sql =
"SELECT Users.Email FROM Users LEFT JOIN Accounts ON Users.Email = Accounts.Email WHERE Accounts.Email IS NULL AND Users.Type > 1 ORDER BY Email ASC";
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
            <input type="submit" value="Insert User Info"></font></td>
        </tr>

    <tr>
        <td><font face="arial, helvetica" size="-1">
            <b>Name</b><br>
            <font size="+1">
            <input name="name" value="" size=20>
            </font></font></td>
        <td><font face="arial, helvetica" size="-1">
            <b>Phone</b><br>
            <font size="+1">
            <input name="phone" value="(604) 291-" size=10>
            </font></font></td>
    <tr>
        <td colspan="2"><font face="arial, helvetica" size="-1">
            <b>Department</b><br>
            <select name="department" value="">
            <option>
            <option>Faculty of Applied Sciences
            <option>Centre for Systems Science
            <option>School of Computing Science
            <option>School of Engineering Science
            <option>School of Kinesiology
            <option>School of Communication
            <option>School of Resource and Environmental Management
            <option>Applied Sciences Continuing Education
            <option>
            <option>Simon Fraser University
            <option>Guest
            <option>Nobody
            </select>
            </font></td>
        </tr>
    </table>

    <p>



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

