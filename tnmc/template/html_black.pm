package tnmc::template::html_black;

use strict;
use warnings;

#
# module configuration
#

BEGIN {
    use tnmc::config;
    use tnmc::security::auth;

    use vars qw();
}

#
# module routines
#

sub header {

    # header and title
    print "Content-Type: text/html; charset=utf-8\n\n";

    &tnmc::security::auth::authenticate();

    my $font_size = get_font_size();
    my $username  = $USERID{'username'} || '';

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


.tnmcMenu {
    width: 120px;
    position:absolute;
    font-size: 9pt;
    padding: 10px;
    text-align:left;
    align: right;
    background: 9999ff;
    right: 10px;
}

.tnmcMain {
    width: 100%;
      padding-right: 130px;
}

body {

}
</style>
<TITLE>TNMC Online</TITLE>
<base href="$tnmc_url">
</HEAD>

<body bgcolor="000000" text="aaaacc" link="9999ff" vlink="6666cc"

>

    };

    print qq{

	    <div id="aboutDiv" class="tnmcMenu">
	};
    &show_menu();

    print qq{
    </div>
    <div id="mainDiv" class="tnmcMain">
};

}

sub footer {

    print qq{
	</div>
	</body><\html>
	    };
}

###################################################################
sub show_menu {

    require tnmc::menu;
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
    <table border="0" cellpadding="1" cellspacing="0" bgcolor="333333" width="100%">
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
