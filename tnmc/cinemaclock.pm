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

	#<a href="/aw/crva.aw/bri/Vancouver/e/9144/Imax__Deep_Sea.html"><span class=movietitlelink>Imax: Deep Sea</span></a>
        while ($movie_text =~ s|<a href="/aw/crva.aw/bri/Vancouver/e/(.*?)/(.*?)"><span class=movietitlelink>(.*?)</span>.*?/10||s)
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
	}
    }
    
    return \@MOVIES;
}


1;
