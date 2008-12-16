package tnmc::cinemaclock;

use strict;

#
# module configuration
#
BEGIN
{
    use LWP::UserAgent;
    use HTTP::Request::Common qw(POST);
    
    use tnmc::general_config;
}

#
# module routines
#

my $ua;
sub get_valid_ua{

    if (! $ua){
	$ua = new LWP::UserAgent;
	$ua->cookie_jar({});
	
	my $URL1 = "http://www.cinemaclock.com/clock/bri/Vancouver.html";
	my $req = new HTTP::Request GET => $URL1;
	my $res = $ua->request($req);
	
#	my $URL2 = "http://www.film-can.com/cgi-bin/main/index.cgi?REGION=20";
#	my $req = new HTTP::Request GET => $URL2;
#	my $res = $ua->request($req);
    }
    return $ua;
}

sub get_theatre_showtimes(){
    my ($cinemaclockid) = @_;
    
    ## get webpage
    my $ua = &get_valid_ua();
    my $URL = "http://www.cinemaclock.com/aw/ctha.aw?p=clock&r=bri&m=Vancouver&j=e&k=$cinemaclockid&submit=Go%21";
    print "DEBUG: Requesting $URL\n";
    my $req = new HTTP::Request GET => $URL;
    my $res = $ua->request($req);
    my $text = $res->content;

    ## parse webpage
    my @MOVIES;
    if ($text =~ m|<!-- underaddress -->(.*)<!-- BIGBOX -->|si){
	my $movie_text = $1;

# <span class=arial1><br></span><a href="/aw/crva.aw/bri/Vancouver/e/11184/Wall-E.html"><span class=movietitlelink>Wall-E</span></a>
# <span class=arial2><font color=#0000aa> (G) </font></span>
# <span class=arial2><font color=#440088>[1:37] </font></span>
# <span class=arial2><font color=#444444>5 weeks</font></span> 

# <!-- nosol --><a href="/aw/crva.aw/bri/Vancouver/e/11184/0/Wall-E.html"><span class=verdana2><font color=#aa0000>8.9</font></span><span class=verdana1>/10</span></a>
# <br><span class=arial2><table border=0 cellspacing=0 cellpadding=1 width="100%"><tr><td width=5><img src="/html/1x1.gif" height=1 width=1></td></tr></table>

# <table border=0 cellspacing=0 cellpadding=1 width="100%"><tr><td width=5><img src="/html/1x1.gif" height=1 width=1></td><td><span class=arial2>Tue, Wed, Thu: 12:20, 1:55, 2:50, 4:20, 5:25, 7:05, 9:35</span></td></tr></table>

	# The \1 is to trim out everything up to and including the last reference to this movie ID.  It
	# appears to be very CPU intensive.
        while ($movie_text =~ s|<a href="/aw/crva.aw/bri/Vancouver/e/(.*?)/(.*?)"><span class=movietitlelink>(.*?)</span>.*\1||s)
	{
	    my $cinemaclockid = $1;
            my $page = $2;
	    my $title = $3;

            $title =~ s| - Eng. Subt.||;
            $title =~ s|Imax: ||;
	    $title = &tnmc::movies::movie::reformat_title($title);

            print "$cinemaclockid   $title    $page\n";
	    my %movie = (
			 "cinemaclockid" => $cinemaclockid,
                         "page" => $page,
			 "title" => $title,
			 );
	    push @MOVIES, \%movie;

	    # Strip out any more references to the same movie URL, or they will mess up our parsing
	    #$movie_text =~ s|<a href="/aw/crva.aw/bri/Vancouver/e/$cinemaclockid/$page"><span class=movietitlelink>||g;
	}
    }
    
    return \@MOVIES;
}


1;
