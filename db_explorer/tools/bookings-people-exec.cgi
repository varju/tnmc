#!/usr/local/bin/perl

##################################################################
#	Scott Thompson - scottt@css.sfu.ca (jan/99)
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

$cgih = new CGI;

print $cgih -> header();
print '<font face="arial, helvetica" size="-1">';

########################################################
### Get all the little variables that we'll want to use.
	# email, name, phone, department
	
$email = $cgih -> param('email');
$name = $cgih -> param('name');
$phone = $cgih -> param('phone');
$dept = $cgih -> param('department');

$sql = "REPLACE INTO Accounts (Email, Name, Password, Dept, Phone, Alias) VALUES ('$email', '$name', '', '$dept', '$phone', '')";

$database = "fasBookings";
$host = "adhara";
$user = "fasBookings";
$password = "quack";

############################
### Do the date stuff.
open (DATE, "/bin/date +%Y%m%d%H%M%S |");
while (<DATE>) {
    chop;
    $today = $_;
}
close (DATE);


########################################################
### Make a log

$log_sql = $sql;
$log_sql =~ s/\n/ /g;

open (LOG, ">>run.log");
print LOG "$today\t$database\t$user\t\"$logsql\"\n";
close (LOG);

########################################################
### Do the database thing

		print <<_HTML;
		<!----------------------------------- H E A D E R ---------------------------------------->

		<title>scott's database tools: sql command results</title>
		<body bgcolor="#ffffff">

		<font face="arial,helvetica" size="+2"><b>
		scott's database tools: sql command results</b></font>
		<hr noshade>

		<b>SQL: </b>$sql<br>
		<b>database: </b>$database<br>
		<b>host: </b>$host<br>
		<b>user: </b>$user<br>
	
_HTML


	#############
	### connect to the database

		print "\n\n\n<p><hr noshade>";
		
		# say hello.
		$dbh = DBI->connect("DBI:mysql:$database:$host", $user, $password);
		print "<font size=\"+1\">dbh->connect(\"DBI:mysql:$database:$host\", $user, $password)</font><br>";
		print '<b>errstr: </b>"' . $dbh->errstr . '"';

	#############
	### Do some sql...

		print "\n\n\n<p><hr noshade>";

		$sth = $dbh->prepare($sql); 
			print '<font size="+1">dbh->prepare(sql)</font><br>';
			print '<b>errstr: </b>"' . $dbh->errstr . '"';
	
			print "\n\n\n<p><hr noshade>";
		
		$sth ->execute;
			print '<font size="+1">sth->execute()</font><br>';
			print '<b>errstr: </b>"' . $dbh->errstr . '"<br>';

			print '<b>fetchrow_array: </b><br>';

			print "<table border=1 cellpadding=2>\n";
			while (@row = $sth->fetchrow_array){
				print "<tr>";
				foreach (@row)
				{	print "<td bgcolor=\"white\"><font size=\"-1\">$_</font></td>";
				}
				print "</tr>\n";
			}
			print "</table>\n";

		$sth ->finish;

#############
### Adios

	$dbh ->disconnect;

		print <<_HTML;

	
<p>
<!----------------------------------- F O O T E R ---------------------------------------->
</font><hr noshade>
</body> </html>

<div align="right"><i>- database complete</i></div>

_HTML
					
### keepin' perl happy...