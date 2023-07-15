package tnmc::template::html_orig;

use strict;
use warnings;

#
# module configuration
#

BEGIN {
    use tnmc::config;
    require tnmc::menu;
    use tnmc::security::auth;

    use vars qw();
}

#
# module routines
#

sub header {

    # header and title
    print "Pragma: no-cache\n";
    print "Expires:Thu Jan  1 00:00:00 1970\n";
    print "Content-Type: text/html; charset=utf-8\n\n";

    &tnmc::security::auth::authenticate();

    my $username  = $USERID{'username'} || '';
    my $logo      = 'basic.gif';
    my $colour_bg = $USERID{'colour_bg'} || '#99ff00';
    if ($colour_bg eq 'random') {
        $colour_bg = rand(999999);                   # get a random colour
        $colour_bg =~ tr/0123456789/0014589adef/;    # make the colour glow
    }
    my $font_size = get_font_size();

    print qq{
<HTML>
<HEAD>

<style>
p, ul, td, th, h1,h2,h3,h4,h5,h6, font, b, i, a {
    font-family: verdana, helvetica, arial, sans-serif;
}

p, ul, td, th {
    font-size: $font_size;
}

th {
    font-weight: bold;
    background: #cccccc;
    text-align: left;
    color: #888888;
}

.menulink {
    font-family: verdana, helvetica, arial, sans-serif;
    font-size: $font_size;
    color: #00067F;
    text-decoration: none;
}
</style>

<TITLE>TNMC Online</TITLE>
<base href="$tnmc_url">
</HEAD>

<BODY BGCOLOR="$colour_bg">
<center>

<TABLE BORDER="0" CELLPADDING=0 CELLSPACING=0 background="">
<TR>
  <TD colspan="4" BACKGROUND="template/top_center_bg.gif"  bgcolor="2266aa">
    <TABLE BORDER="0" CELLPADDING=0 CELLSPACING=0>
    <TR>
      <TD BACKGROUND="template/blank_dot.gif" bgcolor="$colour_bg"><IMG width="290" height="36" SRC="template/logo/$logo"></TD>
    </TR>
    </TABLE>
  </TD>
  <TD ALIGN="left" bgcolor="2266aa" BACKGROUND="template/top_center_bg.gif"><FONT style="font-size: 20pt" COLOR="#FFFFFF" FACE="verdana" SIZE="+2">
    <B>$username</B></FONT>&nbsp;</TD>
  <TD><IMG SRC="template/top_right.gif"></TD>
</TR>

<TR valign="top">
  <TD bgcolor="ffffff" BACKGROUND="template/body_bg.gif">&nbsp;</td>
  <TD bgcolor="ffffff"><br>
    };
}

###################################################################
sub footer {
    my ($pageID) = @_;

    print q{
  <br></TD>

  <TD bgcolor="ffffff">
    <img src="template/blank_dot.gif" width="13" height="1"></td>
  <TD bgcolor="ffff88" background="template/menu_bg.gif">
    <img src="template/blank_dot.gif" width="13"></td>
  <TD bgcolor="ffff88" background="template/menu_bg_cp.gif" VALIGN="TOP">
    <FONT style="text-decoration:none;" COLOR="#00067F" FACE="verdana" SIZE="-2">
	<br>
    };

    if (!$pageID) {
        &show_menu();
    }
    else {
        print "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<br>";
    }

    print qq{
    </font>
  </TD>

  <TD bgcolor="ffff88" background="template/body_right_bg2.gif">&nbsp;</TD>
</TR>

<TR>
  <td><img src="template/bottom_left2.gif"></td>
  <td bgcolor="888888" colspan="2" BACKGROUND="template/bottom_bg_cp.gif">
    <FONT FACE="verdana" SIZE="-2">
    <a href="" style="text-decoration:none"><font color="000000">$tnmc_url</a>
    </FONT></td>
  <TD bgcolor="888888" BACKGROUND="template/menu_bottom_bg.gif">&nbsp;</TD>
  <TD bgcolor="888888" BACKGROUND="template/menu_bottom_bg_cp.gif">
    <FONT FACE="verdana" SIZE="-2">
    };

    if (!$pageID) {
        print q{
    <a href="site_info.cgi" style="text-decoration:none"><font color="#000000">site info</font></a>
    };
    }
    else {
        print "<BR>\n";
    }

    print q{
    </FONT></TD>

  <TD><IMG SRC="template/bottom_right.gif"></TD>
</tr>
</TABLE>

<br>

</BODY>
</HTML>
    };

}

###################################################################
sub show_menu {

    if ($LOGGED_IN) {
        my $menu = &tnmc::menu::get_menu();
        &tnmc::menu::print_menu($menu);
    }
    else {
        &tnmc::menu::new_nav_login();
    }
}

sub show_menu_item {
    my ($indent, $url, $name, $text) = @_;

    my $indent_text = '';
    while ($indent--) {
        $indent_text .= '&nbsp;&nbsp;&nbsp;';
    }
    if ($ENV{REQUEST_URI} =~ /^$tnmc_url_path\Q$url\E/) {
        print qq{\t\t$indent_text<b><a href="$url" class="menulink">$name</a>$text</b><br>\n};
        return 1;
    }
    else {
        print qq{\t\t$indent_text<a href="$url" class="menulink">$name</a>$text<br>\n};
        return 0;
    }
}

###################################################################
sub show_heading {
    my ($heading_text) = @_;
    print qq{
    <table border="0" cellpadding="1" cellspacing="0" bgcolor="448800" width="100%">
      <tr><td nowrap>&nbsp;<font color="ffffff"><b>
      $heading_text</b></font></td></tr>
    </table>
    };
}

sub get_font_size {
    my $font_size;
    if ($ENV{HTTP_USER_AGENT} =~ /Mozilla.*Gecko/) {
        $font_size = '10pt';
    }
    else {
        $font_size = '8pt';
    }

    return $font_size;
}

1;
