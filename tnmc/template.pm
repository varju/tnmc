package tnmc::template;

use strict;

use tnmc::config;
use tnmc::cookie;
use tnmc::db;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(header footer show_heading);
@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub header{

	&db_connect();
	
	# header and title
	print "Content-type: text/html\n\n";

	&get_cookie();

	my $username = $USERID{'username'};

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

<BODY BACKGROUND="/template/bg.gif">
<center>

<!-- 
    <table height="100%" border="0">
    <tr><td valign="middle">
-->


<TABLE BORDER="0" CELLPADDING=0 CELLSPACING=0 background="">
<TR>
		<TD colspan="4" bgcolor="2266aa" BACKGROUND="/template/top_center_bg.gif"><IMG width="290" height="36" SRC="/template/logo/basic.gif"></TD>
		<TD ALIGN="left" bgcolor="2266aa" BACKGROUND="/template/top_center_bg.gif"><FONT style="font-size: 20pt" COLOR=#FFFFFF FACE="verdana" SIZE="+2"
		><B>$username</B></FONT>&nbsp;</TD>
	
	<TD><IMG SRC="/template/top_right.gif"></TD>

</TR>

<TR valign="top">
	<TD bgcolor="ffffff" BACKGROUND="/template/body_bg.gif">&nbsp;</td>
	<TD bgcolor="ffffff"><br>


	};
}

###################################################################
sub footer{

	my ($pageID) = @_;

	&db_connect();

	print q{




	<br></TD>

	<TD bgcolor="ffffff"><img src="/template/blank_dot.gif"
width="13" height="1"></td>
	<TD bgcolor="ffff88" background="/template/menu_bg.gif"><img
src="/template/blank_dot.gif" width="13"></td>
	
	<TD bgcolor="ffff88" background="/template/menu_bg_cp.gif" 
VALIGN="TOP">

		<FONT style="text-decoration:none;" COLOR="#00067F" FACE="verdana"
SIZE="-2">


	};

	if (!$pageID)
	{
		if ($LOGGED_IN)
		{ 	main::new_nav_menu();
		}
		else
		{	main::new_nav_login();
		}
	}
	else
	{	print "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<br>";
	}

	print q{

	</font>
	</TD>
	
	<TD bgcolor="ffff88" background="/template/body_right_bg2.gif">&nbsp;</TD>
	
</TR>



<TR>
	<td BACKGROUND="/template/bottom_bg.gif"><img src="/template/bottom_left2.gif"></td>
	<td bgcolor="888888" colspan="2" BACKGROUND="/template/bottom_bg_cp.gif"><FONT FACE="verdana" SIZE="-2">
		<a href="/" style="text-decoration:none"><font color="000000">$tnmc_url</a>
	</FONT></td>
	<TD bgcolor="888888" BACKGROUND="/template/menu_bottom_bg.gif">&nbsp;</TD>
	<TD bgcolor="888888" BACKGROUND="/template/menu_bottom_bg_cp.gif"><FONT FACE="verdana" SIZE="-2">
	};
	
	if (!$pageID) 
	{ 	print qq 
		{	<a href="/site_info.cgi" style="text-decoration:none"><font color="#000000">site info</font></a>
		};
	}
	else { print "<BR>"; }

	print q{
	</FONT></TD>
	
	<TD><IMG SRC="/template/bottom_right.gif"></TD>
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

1;
