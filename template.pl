##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

require 5.004;
use strict;
use DBI;
use CGI;
require 'db_access.pl';

###################################################################
sub header{

	&db_connect();
	
	# header and title
	print "Content-type: text/html\n\n";

	&get_cookie();

	my $username = $USERID{'username'};


#	my ($now, @names);
#	
#	my $cgih = new CGI;
#	print $cgih -> header();
#
#	open (LOG, '>> log/all.log');
#	print LOG "$now $username	$ENV{REQUEST_URI}";
#	@names =  $cgih->param();
#	foreach (@names){
#		print LOG " +$_=" . $cgih->param($_);
#	}
#	print LOG "\n";
#	close (LOG);

	my $LOGOIMAGE = "http://tnmc.dhs.org/template/logo/basic.gif";

	print qq{


<HTML>
<HEAD>


<style>

p, ul, td, th, h1,h2,h3,h4,h5,h6, font, b, i, a {
        font-family: verdana, helvetica, arial, sans-serif;
}

p, ul, td, th {
        font-size: 8pt;
}

th{
	font-weight: bold;
	background: #cccccc;
	text-align: left;
	color: #888888;
}

.menulink {
        font-family: verdana, helvetica, arial, sans-serif;
        font-size: 8pt;
	color: #00067F;
        text-decoration: none;
}

</style>

	
	<TITLE>TNMC Online</TITLE>
</HEAD>

<BODY BACKGROUND="http://tnmc.dhs.org/template/bg.gif">
<center>

<!-- 
    <table height="100%" border="0">
    <tr><td valign="middle">
-->


<TABLE BORDER="0" CELLPADDING=0 CELLSPACING=0 background="">
<TR>
		<TD colspan="4" bgcolor="2266aa" BACKGROUND="http://tnmc.dhs.org/template/top_center_bg.gif"><IMG width="290" height="36" SRC="$LOGOIMAGE"></TD>
		<TD ALIGN="left" bgcolor="2266aa" BACKGROUND="http://tnmc.dhs.org/template/top_center_bg.gif"><FONT style="font-size: 20pt" COLOR=#FFFFFF FACE="verdana" SIZE="+2"
		><B>$username</B></FONT>&nbsp;</TD>
	
	<TD><IMG SRC="http://tnmc.dhs.org/template/top_right.gif"></TD>

</TR>

<TR valign="top">
	<TD bgcolor="ffffff" BACKGROUND="http://tnmc.dhs.org/template/body_bg.gif">&nbsp;</td>
	<TD bgcolor="ffffff"><br>


	};
}

###################################################################
sub footer{

	my ($pageID) = @_;

	&db_connect();

	print q{




	<br></TD>

	<TD bgcolor="ffffff"><img src="http://tnmc.dhs.org/template/blank_dot.gif"
width="13" height="1"></td>
	<TD bgcolor="ffff88" background="http://tnmc.dhs.org/template/menu_bg.gif"><img
src="http://tnmc.dhs.org/template/blank_dot.gif" width="13"></td>
	
	<TD bgcolor="ffff88" background="http://tnmc.dhs.org/template/menu_bg_cp.gif" 
VALIGN="TOP">

		<FONT style="text-decoration:none;" COLOR="#00067F" FACE="verdana"
SIZE="-2">


	};

	if (!$pageID)
	{
		if ($LOGGED_IN)
		{ 	&new_nav_menu();
		}
		else
		{	&new_nav_login();
		}
	}
	else
	{	print "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<br>";
	}

	print q{

	</font>
	</TD>
	
	<TD bgcolor="ffff88" background="http://tnmc.dhs.org/template/body_right_bg2.gif">&nbsp;</TD>
	
</TR>



<TR>
	<td BACKGROUND="http://tnmc.dhs.org/template/bottom_bg.gif"><img src="http://tnmc.dhs.org/template/bottom_left2.gif"></td>
	<td bgcolor="888888" colspan="2" BACKGROUND="http://tnmc.dhs.org/template/bottom_bg_cp.gif"><FONT FACE="verdana" SIZE="-2">
		<a href="http://tnmc.dhs.org/" style="text-decoration:none"><font color="000000">http://tnmc.dhs.org/</a>
	</FONT></td>
	<TD bgcolor="888888" BACKGROUND="http://tnmc.dhs.org/template/menu_bottom_bg.gif">&nbsp;</TD>
	<TD bgcolor="888888" BACKGROUND="http://tnmc.dhs.org/template/menu_bottom_bg_cp.gif"><FONT FACE="verdana" SIZE="-2">
	};
	
	if (!$pageID) 
	{ 	print qq 
		{	<a href="/site_info.cgi" style="text-decoration:none"><font color="#000000">site info</font></a>
		};
	}
	else { print "<BR>"; }

	print q{
	</FONT></TD>
	
	<TD><IMG SRC="http://tnmc.dhs.org/template/bottom_right.gif"></TD>
</tr>
</TABLE>

<!--
    </td></tr></table>
-->
<br>

</BODY>

</HTML>


	

	};

	&db_disconnect();
}

###################################################################
sub show_heading{
	my ($heading_text, $colour, $junk) = @_;
	print qq{
		<table border="0" cellpadding="1" cellspacing="0" 
bgcolor="448800" width="100%">
		<tr><td nowrap>&nbsp;<font color="ffffff"><b>
		$heading_text</b></font></td></tr></table>
	};
}

#Make Perl happy
return 1;
