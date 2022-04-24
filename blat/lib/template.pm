package lib::template;
use strict;

BEGIN {
    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $fontsize);

    $VERSION = 0.10;

    @ISA = qw(Exporter);

    @EXPORT = qw(header
      show_heading
      footer
      table_open
      table_close
      table_title
    );

    %EXPORT_TAGS = ();

}

sub erin_roommate_log {

    my @bad_ips = (
        "209.53.250.32",    # possible ip from blat logs
        "209.148.236.37"    # antiflux hit from evan
    );

    my $remote_ip = $ENV{REMOTE_ADDR};

    foreach my $bad_ip (@bad_ips) {
        if ($remote_ip eq $bad_ip) {

            my $message = "Hit from: $remote_ip\n\n";
            $message .= join("\n", %ENV);

            my %message = (
                'To:'      => "erin\@antiflux.org",
                'Cc:'      => "scottt\@webct.com",
                'From:'    => "scottt\@webct.com",
                'Subject:' => "Blat site log",
                'Body'     => $message
            );

            require lib::email;
            &lib::email::send_email(\%message);
        }
    }
}

sub header {
    my $title = "blatsite!";

    print "Content-type: text/html\n\n";
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
    &show_heading("<img border=0 height=30 src=\"/blat/pics/misc/blatlogoR_small.jpg\">",
        "http://jello.webct.com/blat/");

}

sub footer {

    &show_heading();
    print qq{
                </body>
                </html>
    };

    &erin_roommate_log();
}

sub show_heading {
    my ($title, $url) = @_;
    $title ||= '&nbsp;';
    $url = qq{<a href="$url">} if $url;
    print qq{
        <table width="100%" cellspacing="0" border="0"><tr>
        <td bgcolor="113366" align="right">
            $url
        <font color="ff8800" face="sans-serif" size="+2">
            <b>$title</b></font></a>&nbsp;&nbsp;&nbsp;
        </td></tr>

        </table>
    };

}

sub table_open {
    print "<table width=\"100%\" border=0 cellspacing=0 cellpadding=3>\n";
}

sub table_close {
    print "</table>\n";
}

sub table_title {
    my ($title) = @_;
    print "<tr><td colspan=10 bgcolor='ffeedd'><b><font color='dd6600'>$title</font></b></td></tr>\n";
}

return 1;

