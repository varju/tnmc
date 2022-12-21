package tnmc::template::html_blat;

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
    my $title = "blatsite!";

    &tnmc::security::auth::authenticate();

    print "Content-Type: text/html; charset=utf-8\n\n";
    print qq{
            
                <html>
                <head>
                
<style>

p, ul, td, th, h1,h2,h3,h4,h5,h6, font, b, i, a {
    font-family: verdana, helvetica, arial, sans-serif;
}

th {
    font-weight: bold;
    background: #dd6e00;
    text-align: left;
    color: #442200;
}

</style>
    
<title>$title</title>
<base href="$tnmc_url">
</head>
                
<body
    LEFTMARGIN="40" TOPMARGIN="40" MARGINWIDTH="40" MARGINHEIGHT="40"
    bgcolor="#ee7700"
    text="#553311"
    link="#000000"
    alink="#113366"
    vlink="#442200"
    >

    };
    my $userline;
    if ($USERID) {
        $userline = qq{
	    $USERID{username}
	    <font size="-3">
		[<a href="user/my_prefs.cgi"><font color="ff8800">preferences</font><a>]
	    </font>
	};
    }
    else {
        require tnmc::teams::roster;
        require tnmc::teams::team;
        require tnmc::user;
        my $teamID = 1;
        my $team   = tnmc::teams::team::get_team_extended($teamID);
        my @users  = &tnmc::teams::roster::list_users($teamID);
        @users = sort tnmc::user::by_username @users;

        $userline = qq{
	    <table cellpadding=0 cellspacing=0 border=0>
	    <form action="$tnmc_url/user/login.cgi" method="post">
	    <input type="hidden" name="location" value="$tnmc_url/$team->{action}->{view}">
	    <tr><td>
                <select name="userID">
		    <option value="0">Login...
                    <option value="0">--------
		    };
        foreach my $userID (@users) {
            my $user = &tnmc::user::get_user($userID);
            $userline .= qq{
		<option value="$userID">$user->{username}</option>
		};
        }
        $userline .= qq{
		</select>
                <input type="password" name="password" size="6">
		<input type="submit" value="go">
	    </td></tr>
	    </form>
	    </table>
		
	    
        </form>
	};
    }

    &show_blue_block($userline, "<img border=0 height=30 src=\"template/html_blat/blatlogoR_small.jpg\">",
        "", $tnmc_url);
}

sub footer {
    print qq{
	<p>
	};
    &show_blue_block();
    print qq{
                </body>
                </html>
    };

}

###################################################################

sub show_heading {
    my ($title) = @_;
    $title ||= '&nbsp;';
    print qq{
        <table width="100%" cellspacing="0" border="0"><tr>
        <td bgcolor="ffffff" align="left">
        <font color="ff8800" face="sans-serif" size="+1">
            &nbsp;$title</font>&nbsp;&nbsp;&nbsp;
        </td></tr>

        </table>
    };

}

sub show_blue_block {
    my ($left, $right, $lurl, $rurl) = @_;
    $lurl = qq{<a href="$lurl">} if $lurl;
    $rurl = qq{<a href="$lurl">} if $rurl;
    print qq{
        <table width="100%" cellspacing="0" border="0"><tr>
	    <td bgcolor="113366" align="left" nowrap>
		$lurl
		<font color="ff8800" face="sans-serif" size="+2">
		    <b>$left</b></font></a>
            </td>
	    <td bgcolor="113366" align="right" nowrap>
		$rurl
		<font color="ff8800" face="sans-serif" size="+2">
		<b>$right</b></font></a>&nbsp;&nbsp;&nbsp;
            </td>
	    </tr>

        </table>
    };

}

1;
