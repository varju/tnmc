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

	my ($cgih, $title, %user, $username, $moo, @names, $now);

	&db_connect();
	
		# header and title
	$cgih = new CGI;
	print $cgih -> header();

	&get_cookie();

	if ($USERID > 0)
	{	&get_user($USERID, \%user);
		$username = $user{'username'};
	}

#	open (LOG, '>> log/all.log');
#	print LOG "$now $username	$ENV{REQUEST_URI}";
#	@names =  $cgih->param();
#	foreach (@names){
#		print LOG " +$_=" . $cgih->param($_);
#	}
#	print LOG "\n";
#	close (LOG);

	$title = "tnmc";
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


<TABLE BORDER="0" CELLPADDING=0 CELLSPACING=0
background="">
<TR>
		<TD colspan="4" bgcolor="2266aa"
BACKGROUND="http://tnmc.dhs.org/template/top_center_bg.gif"><IMG width="290"
height="36" SRC="$LOGOIMAGE"></TD>

		<TD ALIGN="left" bgcolor="2266aa"
BACKGROUND="http://tnmc.dhs.org/template/top_center_bg.gif"><FONT style="font-size:
20pt" COLOR=#FFFFFF FACE="verdana" SIZE="+2"
		><B>$username</B></FONT>&nbsp;</TD>
	
	<TD><IMG SRC="http://tnmc.dhs.org/template/top_right.gif"></TD>

</TR>

<TR valign="top">
	<TD bgcolor="ffffff" BACKGROUND="http://tnmc.dhs.org/template/body_bg.gif">&nbsp;</td>
	<TD bgcolor="ffffff"><br>


	};
}

###################################################################
sub new_nav_login{

	my (@row, $userID, %user, $hits, $sth, $sql);

                print qq
                {
			<form action="/login.cgi" method="post">
		        <br><b>Login:</b><br>
                        <!-- <select onChange="form.submit();" name="userID"> -->
			<select name="userID">
                        <option value="0">Pick a user...
                        <option value="0">---------------
                };

                $sql = "SELECT userID, username FROM Personal ORDER BY username";
                $sth = $dbh_tnmc->prepare($sql);
                $sth->execute();
                
                while (@row = $sth->fetchrow_array()){
                        print qq{
                               <option value="$row[0]">$row[1]
                        };
                };
    
                print qq 
                {       </select><br>
			<b>Password:</b><br>
			<input type="password" name="password" size="10"><br>
                        <input type="image" border=0 src="http://tnmc.dhs.org/template/go_submit.gif" alt="Go"><br>
                        </form>
			<p>
			Hello there!<br>
			<br>
			Welcome to TNMC<I>Online</I>, <BR>a perl web-app and<BR>
			full-fledged sql <BR>database, dedicated<BR>
			solely to figuring <BR>out which movie to<BR>
			go to every week.
			<p>
			
			<u><b>Notice to Visitors:</b></u><br>
			If you are not a<br> regular user and<br>
			would like to browse<br> the site, please<br>
			login as user <b>demo</b>.<br>
			
			<br>
			<p>
                };
			
}

###################################################################
sub show_menu_item{
	my ($indent, $url, $name, $text) = @_;
	
	my $indent_text = '';
	while($indent--){
		$indent_text .= '&nbsp;&nbsp;&nbsp;';
	}
	if ($ENV{REQUEST_URI} =~ /^\Q$url\E/){
		print qq{\t\t$indent_text<b><a href="$url" class="menulink">$name</a>$text</b><br>\n};
		return 1;
	}
	else{
		print qq{\t\t$indent_text<a href="$url" class="menulink">$name</a>$text<br>\n};
		return $HOMEPAGE
	}
}

###################################################################
sub new_nav_menu{

	my (%user);
	&get_user($USERID, \%user);

	### this test should be elsewhere.
	$HOMEPAGE =  ($ENV{REQUEST_URI} eq '/' || $ENV{REQUEST_URI} eq 'index.cgi');

	&show_menu_item( 0, "", "", "");
	&show_menu_item( 0, "http://tnmc.dhs.org/", "Home", "");
	&show_menu_item( 0, "", "", "");
	# &show_menu_item( 0, "/announcements/", "Announcements", "");
	# &show_menu_item( 0, "", "", "");

	&show_menu_item( 0, "/people/", "People", "");
	&show_menu_item( 0, "", "", "");

	if (&show_menu_item( 0, "/movies/", "Movies", "")){
		&show_menu_item( 1, "/movies/index.cgi?sortOrder=order", "Ordered", "");
		&show_menu_item( 1, "/movies/index.cgi?sortOrder=title", "Alphabetical", "");
		&show_menu_item( 1, "", "", "");
		&show_menu_item( 1, "/movies/attendance.cgi", "Attendance", "");
		&show_menu_item( 1, "/movies/list_seen_movies.cgi", "Seen", "");
		&show_menu_item( 1, "/movies/movie_add.cgi", "Add&nbsp;a&nbsp;Movie", "");
		&show_menu_item( 1, "/movies/help.cgi", "Info", "");
		if ($user{groupAdmin}){
			&show_menu_item( 1, "", "", "");
			&show_menu_item( 1, "/movies/admin.cgi", "Admin", "");
			&show_menu_item( 1, "/movies/list_all_movies.cgi", "All&nbsp;Movies", "");
			&show_menu_item( 1, "/movies/movies.cgi", "Testing", "");
		}
	}
	&show_menu_item( 0, "", "", "");

	&show_menu_item( 0, "/broadcast/", "Broadcast", "");
	&show_menu_item( 0, "", "", "");

	&show_menu_item( 0, "/fieldtrip/", "FieldTrips", "");

	if ($USERID == '1'){
		print qq{
		};
	}
	if ($user{groupAdmin}){
		print qq{
			<p>
			<hr noshade size="1">
			<p>
			<a href="/admin/" class="menulink">Admin</a>
			<p>
			<a href="/bulletins/" class="menulink">Bulletins</a>
			<p>
		};
	}
	if ($user{groupDev}){
		print qq{
			<a href="/development/db_explorer/database.cgi?tnmc" class="menulink">db Explorer</a>
			<p>
			<a href="/development/" class="menulink">Development</a>
			<p>
		}
	}
	print qq{
		<p>
		<hr noshade size="1">
		<p>
	 	<a href="/people/my_prefs.cgi" class="menulink">Preferences</a>
		<P>
		<a href="/logout.cgi" class="menulink">Log Out</a>
		<p>
		<br>

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
