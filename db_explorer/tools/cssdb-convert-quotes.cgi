#!/usr/local/bin/perl

##################################################################
#	Scott Thompson - scottt@css.sfu.ca (nov/98)
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

######################
### Get all the little variables that we'll want to use.
	
	$cgih = new CGI;
	print $cgih -> header();
	
#####################
### Do the database thing

	#############
	### connect to the database
		$database = "csstest";
		$host = "adhara";
		$user = "dbmgr";
		$password = "gordonr";
		
		# say hello.
		$dbh = DBI->connect("DBI:mysql:$database:$host", $user, $password) or die "Can't connect: $dbh->errstr\n";


##########################################################
#### The Beginning of the HTML.

$title = 'db tools: cssdb - convert quotes for Dr. Gruver';

print qq{
<!----------------------------------- H E A D E R ---------------------------------------->

		<title>$title</title>
		<body bgcolor="#ffffff">
	
		<font face="arial,helvetica" size="+2"><b>
		$title</b></font>
		<hr noshade>
		<font face="arial, sans-serif">
		<p>
<!----------------------------------- D A T A ---------------------------------------->
};

	#############
	### Do the DB stuff

print q{
	<font color="#ff00ff" size="+1">You really oughtn't be using this script.<br>
	(fortunately I've commented out everything important)<p></font>
};

	$sql="SELECT Publications.PubID, Publications.BiblioString FROM Publications, Authors WHERE Authors.MemberID='17' AND Publications.PubID = Authors.PubID";

	print "<b>SQL:</b><br>$sql";


	$sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
	$sth ->execute or die "Can't execute: $dbh->errstr\n";
	while (@row = $sth->fetchrow_array){
		($PubID, $BiblioString, $junk) = @row;
		print qq{$PubID<br><font color="#808000">\n$BiblioString</font><p>\n};
		$BiblioString =~ s/"/&#39/gs;
		print "$BiblioString<p>\n";

#		$sql2="UPDATE Publications SET BiblioString='$BiblioString' WHERE PubID='$PubID'";
#		$sth2 = $dbh->prepare($sql2) or die "Can't prepare $sql:$dbh->errstr\n";
#		$sth2 ->execute or die "Can't execute: $dbh->errstr\n";
#		$sth2 ->finish;

		
	}	
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



