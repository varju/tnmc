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

        while ($movie_text =~ s|<a href="/movies/bri/Vancouver/(\d+?)/([^\"]+?)"><span class=movietitlelink>(.*?)</span>(.*?<span class=arial1>)?||s)
	{
	    my $cinemaclockid = $1;
            my $page = $2;
	    my $title = $3;
	    my $after = $4;

            $title =~ s| - Eng. Subt.||;
            $title =~ s|Imax: ||;

	    add_movie(\@MOVIES, $cinemaclockid, $page, $title);

	    if (defined($after) && $after =~ /Also playing in 3D/)
	    {
		add_movie(\@MOVIES, $cinemaclockid . '.3d', $page, $title . ' 3D');
	    }
	}
    }

    return \@MOVIES;
}

sub add_movie
{
    my ($movies, $cinemaclockid, $page, $title) = @_;
    my $pretty_title = &tnmc::movies::movie::reformat_title($title);
    my %movie = ( "cinemaclockid" => $cinemaclockid, "page" => $page, "title" => $pretty_title );
    push @$movies, \%movie;
}

1;
