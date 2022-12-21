package tnmc::template::html_2003;

use strict;

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

    my $browser = ($ENV{HTTP_USER_AGENT} =~ /MSIE/) ? 'IE' : 'NS';

    my $font_size = ($ENV{HTTP_USER_AGENT} =~ /Mozilla.*Gecko/) ? '10pt' : '8pt';

    my $menu_width = ($browser eq 'IE') ? '120px' : '100px';

    my $username = $USERID{'username'} || '';

    print <<__HTML;
<HTML>
<HEAD>

<style>
p, ul, td, th, h1,h2,h3,h4,h5,h6, font, b, i, a {
    font-family: verdana, helvetica, arial, sans-serif;
}

p, ul, td, th {
    font-size: $font_size;
}

body{
    margin: 0px;
    background: #99ff00;
}

th {
    font-weight: bold;
    background: #cccccc;
    text-align: left;
    color: #bbbbbb;
}

.menulink {
    font-family: verdana, helvetica, arial, sans-serif;
    font-size: $font_size;
    color: #00067F;
    text-decoration: none;
}

.controllink {
    font-family: verdana, helvetica, arial, sans-serif;
    font-size: 20;
    color: #ffffff;
    text-decoration: none;
    font-weight: bold ;
}

.tnmcHeading {
    font-family: verdana, helvetica, arial, sans-serif;
    font-size: $font_size;
    color: #ffffff;
    text-decoration: none;
    font-weight: bold ;
}


.tnmcControl {
    margin-top: 20px;
    width: $menu_width;
    position:absolute; 
    font-size: 9pt;
    padding: 10px;
    padding-top: 5px;
    padding-bottom: 5px;
    text-align:left;
    align: right;
    background: "#0E6DA4";
    right: 10px;
    filter:alpha(opacity=100);
    -moz-opacity:100%;
     
}

.tnmcMenuIndent {
    margin-left: 10px;
}
.tnmcMenu {
    margin-top: 55px;
    width: $menu_width;
    position:absolute; 
    font-size: 9pt;
    padding: 10px;
    text-align:left;
    align: right;
    background: "#FFFD7F";
    right: 10px;
    filter:alpha(opacity=100);
    -moz-opacity:100%;
     
}

.tnmcMain {
    width= 100%;
    margin-left: 40px;
    margin-right: 130px;
    margin-top: 20px;
    padding:10px;
    padding-right:20px;
    font-size: $font_size;
    background: #ffffff;
}


.tnmcHeading {
margin-left: 0px;
margin-right: 0px;

}

.tnmcMain {
}

</style>
<script>
<!--
    function toggle_div(layer){
        if (document.getElementById(layer).style.display != "none"){
	    document.getElementById(layer).style.display = "none";
	}
	else{
	    document.getElementById(layer).style.display = "block";
	}
    }


    function fade_layer(layer, opacity){
        document.getElementById(layer).style.filter="alpha(opacity=" + opacity + ")";
    }
    
    var menu_opacity_bri = 100;
    var menu_opacity_dim = 100;
    function hide_menu(){
	if (menu_opacity_dim == 50){
	    menu_opacity_bri = 30;
	    menu_opacity_dim = 00;
	}
	else{
	    menu_opacity_bri = 100;
	    menu_opacity_dim = 100;
	}
	toggle_div("tnmcMenu")
	fade_layer("tnmcMenu", menu_opacity_bri);
    }

-->
</script>

<TITLE>TNMC Online</TITLE>
<base href="$tnmc_url">
</HEAD>

<body text="#000000" link="#9999ff" vlink="#6666cc"
>
    
__HTML

    print qq{
    
	    <div name="tnmcControl" id="tnmcControl" class="tnmcControl">
    <a href="javascript:hide_menu()"
       onMouseOver='javascript:fade_layer("tnmcMenu", menu_opacity_bri)'
       onMouseOut='javascript:fade_layer("tnmcMenu", menu_opacity_dim)'
       class="controllink">$USERID{username}</a><br>
</div>
	    <div name="tnmcMenu"
       onMouseOver='javascript:fade_layer("tnmcMenu", menu_opacity_bri)'
       onMouseOut='javascript:fade_layer("tnmcMenu", menu_opacity_dim)'

 id="tnmcMenu" class="tnmcMenu">
    };

    &show_menu();

    print qq{
    </div>
	<p>

    <div id="mainDiv" class="tnmcMain">
	<div>
    };

}

sub show_menu {
    require tnmc::menu;
    my $menu = &tnmc::menu::get_menu();
    &tnmc::menu::print_menu($menu);
}

my @show_menu_item_indent;

sub show_menu_item {
    my ($indent, $url, $name, $text, $submenu) = @_;

    my $div;
    my $curr_indent = $#show_menu_item_indent + 1;
    my $is_active   = ($ENV{REQUEST_URI} =~ /^$tnmc_url_path\Q$url\E/);
    my $line;

    ## close submenu
    if ($indent < $curr_indent) {
        my $div = pop @show_menu_item_indent;
        print qq{</div>};
    }
    if ($indent > $curr_indent) {
        $div = "menu" . rand();
        push @show_menu_item_indent, $div;
        $line .= qq{<div class="tnmcMenuIndent" style="display:none;" id="$div">};
    }

    $line .= "\t\t";
    if ($is_active) {
        $line .= "<b>";
    }
    $line .= qq{<a href="$url" class="menulink">$name</a>$text};
    if ($is_active) {
        $line .= "</b>";
    }
    if ($submenu) {
        $div = "menu" . rand();
        push @show_menu_item_indent, $div;
        $line .= qq{<a href='javascript:toggle_div("$div")' class="menulink">&nbsp;&#149;&nbsp;</a>};
    }
    $line .= "<br>";
    if ($submenu) {
        if ($is_active) {
            $line .= qq{<div class="tnmcMenuIndent" id="$div">};
        }
        else {
            $line .= qq{<div class="tnmcMenuIndent" style="display:none;" id="$div">};
        }
    }
    print $line;

    # open submenu
}

sub footer {

    print qq{
</div>
	</div>
	</body><\html>
	    };
}

###################################################################
sub show_heading {
    my ($heading_text) = @_;
    my $i = rand();
    print qq{
	</div>
    <table border="0" cellpadding="1" cellspacing="0" bgcolor="006622" width="100%">
      <tr><td nowrap>&nbsp;<font color="#ffffff"><b>
	      $heading_text</b>
	  </font>
	  </td>
	  <td align=right>
	      <a href='javascript:toggle_div("header$i");' class="tnmcHeading">&nbsp;&#149;&nbsp;</a>
          </td></tr>
    </table>
    <div id="header$i" class="tnmcContent">
    };
}

1;
