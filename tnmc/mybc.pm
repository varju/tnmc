package tnmc::mybc;

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

sub mybc_get_movie_list
{
    my %results;

    my $URL = "http://www.mytelus.com/movies/releases.do";
    my $req = new HTTP::Request GET => $URL;
    my $ua = new LWP::UserAgent;
    my $res = $ua->request($req);

    my $text = $res->content;
    if ($text =~ m|<select name="movieID">(.*)</select>|si)
    {
	my $movies = $1;
	my @list = split("\n", $movies);

	foreach my $item (@list)
	{
	    if ($item =~ m|<option value="(\w+)">(.*)$|)
	    {
		next unless $1 && $2;
		$results{$1} = $2;
	    }
	}
    }

    return %results;
}

sub mybc_get_movie_info
{
    my ($mID) = @_;
    my %info;
    $info{mybcID} = $mID;

    my $ua = new LWP::UserAgent;
    my $URL = "http://www.mytelus.com/movies/mdetails.do?movieID=$mID";
    my $req = new HTTP::Request GET => $URL;
    my $res = $ua->request($req);

    my $text = $res->content;
    if ($text =~ m|<form method="get" action="/movies/theatres.do">.*<font class="header" color="#49166d">(.*?)</font>|si)
    {
	$info{title} = $1;
	if ($info{title} =~ /^(The|A)\s+(.*)$/)
	{
	    $info{title} = "$2, $1";
	}
    }
    return () unless $info{title};

    if ($text =~ m|<b>Premise</b></font>\s*<br>\s*(.*?)\s*<br><br>|si)
    {
	$info{premise} = $1;
    }

    if ($text =~ m|<b>our rating</b>.*?<img src="/images/movies/stars/star_(\d+).gif"|si)
    {
	$info{stars} = $1 / 2;
    }
    else
    {
	$info{stars} = 0;
    }

    $URL = "http://www.mytelus.com/movies/theatres.do?prov=BC&movieID=$mID";
    $req = new HTTP::Request GET => $URL;
    $res = $ua->request($req);
    $text = $res->content;

    my %mTheatres = ();
    my @lines = split('\n', $text);
    foreach my $line (@lines)
    {
	if ($line =~ m|<a href="/movies/tdetails.do\?theatreID=(.*?)">(.*?)</a>|si)
	{
	    $mTheatres{$1} = $2;
	}
    }
    $info{theatres} = \%mTheatres;

    return %info;
}

1;
