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

sub update
{
    $| = 1;
    print "Content-type: text/html\n\n<pre>\n";
    
    my $theatres = get_theatres();
    my $showtimes = get_showtimes($theatres);

    print "\n\n";
    print "***********************************************************\n";
    print "****               Update the Database                 ****\n";
    print "***********************************************************\n";
    print "\n\n";

    &tnmc::movies::cron::reset_status_showing();

    ## del old showtimes
    &tnmc::movies::showtimes::del_all_showtimes();

    ## update movies
    foreach my $theatreID (keys %$showtimes) {
	process_theatre($theatreID, $showtimes->{$theatreID});
    }

    ### update the movie caches
    &tnmc::movies::night::update_all_cache_movieIDs();

    &tnmc::db::db_disconnect();
}

sub get_theatres
{
    print "***********************************************************\n";
    print "****           CINEMACLOCK: Get The Theatre List           ****\n";
    print "***********************************************************\n";
    print "\n\n";
    
    my @theatres = &tnmc::movies::theatres::list_theatres("WHERE cinemaclockid != ''");
    print join " ", @theatres;
    print "\n\n";

    return \@theatres;
}

sub get_showtimes
{
    my ($theatres) = @_;

    print "***********************************************************\n";
    print "****           CINEMACLOCK: Get The Showtimes              ****\n";
    print "***********************************************************\n";
    print "\n\n";
    
    my %SHOWTIMES;
    foreach my $theatreID (@$theatres){
	my $theatre = &tnmc::movies::theatres::get_theatre($theatreID);
	print "Theatre: $theatre->{name}\n";
	
	my $showtimes = &tnmc::cinemaclock::get_theatre_showtimes($theatre->{cinemaclockid});
	foreach my $listing (@$showtimes) {
	    print $listing->{cinemaclockid}, "   ", $listing->{title}, "    ", $listing->{page}, "\n";
	}

	$SHOWTIMES{$theatreID} = $showtimes;
	
    }

    return \%SHOWTIMES;
}

## sets new showtimes
sub process_theatre
{
    my ($theatreID, $listings) = @_;

    my $theatre = &tnmc::movies::theatres::get_theatre($theatreID);
    print "$theatre->{name}\n";

    foreach my $listing (@$listings) {
	print "\t$listing->{cinemaclockid}\t$listing->{title} ";

	## find movie
	my $movie = get_or_create_movie($listing->{cinemaclockid}, $listing->{title});

	## update attributes
	$movie->{cinemaclockID} = $listing->{cinemaclockid};
	$movie->{cinemaclockPage} = $listing->{page};
	$movie->{statusShowing} = 1;
	$movie->{title} = $listing->{title};
	&tnmc::movies::movie::set_movie($movie);

	## update showtimes
	add_showtime($theatreID, $movie->{movieID});
	
	print "\n";
    }
}

sub get_or_create_movie
{
    my ($cinemaclockid, $title) = @_;

    my $movie = &tnmc::movies::movie::get_movie_by_cinemaclockid($cinemaclockid);
    if ($movie->{movieID}) {
	print "(cinemaclockid ", $movie->{movieID}, ")";
	return $movie;
    }

    my $movieID = &tnmc::movies::movie::get_movieid_by_title($title);
    if ($movieID) {
	print "(title $movieID)";
	return &tnmc::movies::movie::get_movie($movieID);
    }

    ## add new movie
    $movie = &tnmc::movies::movie::new_movie();
    $movie->{title} = $title;
    $movie->{cinemaclockID} = $cinemaclockid;

    $movie->{statusBanned} = 0;
    $movie->{statusNew} = 1;
    $movie->{statusSeen} = 0;

    $movieID = &tnmc::movies::movie::add_movie($movie);
    print "(new $movieID)";
    return &tnmc::movies::movie::get_movie($movieID);
}

sub add_showtime
{
    my ($theatreID, $movieID) = @_;

    my $showtimes = &tnmc::movies::showtimes::new_showtimes();
    $showtimes->{theatreID} = $theatreID;
    $showtimes->{movieID} = $movieID;
    &tnmc::movies::showtimes::set_showtimes($showtimes);
}

1;
