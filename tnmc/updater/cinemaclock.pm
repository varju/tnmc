package tnmc::updater::cinemaclock;

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
    
use tnmc::general_config;
use tnmc::movies::movie;

sub new
{
    my $self = {};
    $self->{ua} = undef;
    bless($self);
    return $self;
}

sub get_valid_ua
{
    my ($self) = @_;
    if (! $self->{ua}) {
	$self->{ua} = new LWP::UserAgent;
	$self->{ua}->cookie_jar({});
    }
    return $self->{ua};
}

sub get_theatre_showtimes
{
    my ($self, $cinemaclockid) = @_;
    
    ## get webpage
    my $ua = $self->get_valid_ua();
    my $URL = "http://www.cinemaclock.com/aw/ctha.aw/bri/Vancouver/e/$cinemaclockid.html";
    print "DEBUG: Requesting $URL\n";
    my $req = new HTTP::Request GET => $URL;
    my $res = $ua->request($req);
    my $text = $res->content;

    return $self->parse_theatre_showtimes($text);
}

sub parse_theatre_showtimes
{
    my ($self, $text) = @_;

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

	    $self->add_movie(\@MOVIES, $cinemaclockid, $page, $title);

	    if (defined($after) && $after =~ /Also playing in 3D/)
	    {
		$self->add_movie(\@MOVIES, $cinemaclockid . '.3d', $page, $title . ' 3D');
	    }
	}
    }

    return \@MOVIES;
}

sub add_movie
{
    my ($self, $movies, $cinemaclockid, $page, $title) = @_;

    my $pretty_title = &tnmc::movies::movie::reformat_title($title);
    my %movie = ( "cinemaclockid" => $cinemaclockid, "page" => $page, "title" => $pretty_title );
    push @$movies, \%movie;
}

sub update
{
    my ($self) = @_;

    print "Content-type: text/html\n\n<pre>\n";
    
    my $theatres = $self->get_theatres();
    my $showtimes = $self->get_showtimes($theatres);

    print "\n\n";
    print "***********************************************************\n";
    print "****               Update the Database                 ****\n";
    print "***********************************************************\n";
    print "\n\n";

    #print "- reset statusShowing\n";
    &tnmc::movies::cron::reset_status_showing();

    ## del old showtimes
    #print "- delete old showtimes\n";
    &tnmc::movies::showtimes::del_all_showtimes();

    ## update movies
    #print "- update showtimes\n";
    foreach my $theatreID (keys %$showtimes) {
	$self->process_theatre($theatreID, $showtimes->{$theatreID});
    }

    ### update the movie caches
    #print "- update movie caches\n";
    &tnmc::movies::night::update_all_cache_movieIDs();

    #print "- disconnect\n";
    &tnmc::db::db_disconnect();
    #print "- done\n";
}

sub get_theatres
{
    my ($self) = @_;

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
    my ($self, $theatres) = @_;

    print "***********************************************************\n";
    print "****           CINEMACLOCK: Get The Showtimes              ****\n";
    print "***********************************************************\n";
    print "\n\n";
    
    my %SHOWTIMES;
    foreach my $theatreID (@$theatres){
	my $theatre = &tnmc::movies::theatres::get_theatre($theatreID);
	print "Theatre: $theatre->{name}\n";
	
	my $showtimes = $self->get_theatre_showtimes($theatre->{cinemaclockid});
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
    my ($self, $theatreID, $listings) = @_;

    my $theatre = &tnmc::movies::theatres::get_theatre($theatreID);
    print "$theatre->{name}\n";

    foreach my $listing (@$listings) {
	print "\t$listing->{cinemaclockid}\t$listing->{title} ";

	## find movie
	my $movie = $self->get_or_create_movie($listing->{cinemaclockid}, $listing->{title});

	## update attributes
	$movie->{cinemaclockID} = $listing->{cinemaclockid};
	$movie->{cinemaclockPage} = $listing->{page};
	$movie->{statusShowing} = 1;
	$movie->{title} = $listing->{title};
	&tnmc::movies::movie::set_movie($movie);

	## update showtimes
	$self->add_showtime($theatreID, $movie->{movieID});
	
	print "\n";
    }
}

sub get_or_create_movie
{
    my ($self, $cinemaclockid, $title) = @_;

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
    my ($self, $theatreID, $movieID) = @_;

    my $showtimes = &tnmc::movies::showtimes::new_showtimes();
    $showtimes->{theatreID} = $theatreID;
    $showtimes->{movieID} = $movieID;
    &tnmc::movies::showtimes::set_showtimes($showtimes);
}

1;
