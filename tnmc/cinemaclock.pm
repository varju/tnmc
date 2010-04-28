package tnmc::cinemaclock;

use strict;
use warnings;

#
# module configuration
#
BEGIN
{
    use LWP::UserAgent;
    use HTTP::Request::Common qw(POST);
    
    use tnmc::general_config;
    use tnmc::movies::movie;
}

#
# module routines
#

my $ua;
sub get_valid_ua {
    if (! $ua) {
	$ua = new LWP::UserAgent;
	$ua->cookie_jar({});
    }
    return $ua;
}

sub get_theatre_showtimes(){
    my ($cinemaclockid) = @_;
    
    ## get webpage
    my $ua = &get_valid_ua();
    my $URL = "http://www.cinemaclock.com/aw/ctha.aw/bri/Vancouver/e/$cinemaclockid.html";
    print "DEBUG: Requesting $URL\n";
    my $req = new HTTP::Request GET => $URL;
    my $res = $ua->request($req);
    my $text = $res->content;

    return parse_theatre_showtimes($text);
}

sub parse_theatre_showtimes
{
    my ($text) = @_;

    ## parse webpage
    my @MOVIES;
    if ($text =~ m|<!-- BEGINHOURS -->(.*)<!-- ENDHOURS -->|si){
	my $movie_text = $1;

        while ($movie_text =~ s|<a href="/aw/crva.aw/bri/Vancouver/e/(\d+?)/([^\"]+?)"><span class=movietitlelink>(.*?)</span>||s)
	{
	    my $cinemaclockid = $1;
            my $page = $2;
	    my $title = $3;

            $title =~ s| - Eng. Subt.||;
            $title =~ s|Imax: ||;
	    $title = &tnmc::movies::movie::reformat_title($title);

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
