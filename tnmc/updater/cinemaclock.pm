package tnmc::updater::cinemaclock;

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request::Common qw(POST);

use tnmc::general_config;
use tnmc::movies::movie;
use tnmc::updater::base;

use vars qw(@ISA);
@ISA = ("tnmc::updater::base");

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();
    bless($self, $class);
    return $self;
}

sub get_label {
    my ($self) = @_;
    return 'CINEMACLOCK';
}

sub get_type {
    my ($self) = @_;
    return 'cinemaclockID';
}

sub get_theatre_showtimes {
    my ($self, $cinemaclockid) = @_;

    ## get webpage
    my $ua  = $self->get_valid_ua();
    my $URL = "http://www.cinemaclock.com/aw/ctha.aw/bri/Vancouver/e/$cinemaclockid.html";
    print "DEBUG: Requesting $URL\n";
    my $req  = new HTTP::Request GET => $URL;
    my $res  = $ua->request($req);
    my $text = $res->content;

    return $self->parse_theatre_showtimes($text);
}

sub parse_theatre_showtimes {
    my ($self, $text) = @_;

    ## parse webpage
    my @MOVIES;
    if ($text =~ m|<!-- BEGINHOURS -->(.*)<!-- ENDHOURS -->|si) {
        my $movie_text = $1;

        while ($movie_text =~
s|<a href="/movies/bri/Vancouver/(\d+?)/([^\"]+?)"><span class=movietitlelink>(.*?)</span>(.*?<span class=arial1>)?||s
          )
        {
            my $cinemaclockid = $1;
            my $page          = $2;
            my $title         = $3;
            my $after         = $4;

            $title =~ s| - Eng. Subt.||;
            $title =~ s|Imax: ||;

            $self->add_movie(\@MOVIES, $cinemaclockid, $page, $title);

            if (defined($after) && $after =~ /Also playing in 3D/) {
                $self->add_movie(\@MOVIES, $cinemaclockid . '.3d', $page, $title . ' 3D');
            }
        }
    }

    return \@MOVIES;
}

sub add_movie {
    my ($self, $movies, $cinemaclockid, $page, $title) = @_;

    my $pretty_title = &tnmc::movies::movie::reformat_title($title);
    my %movie        = ("cinemaclockID" => $cinemaclockid, "page" => $page, "title" => $pretty_title);
    push @$movies, \%movie;
}

## sets new showtimes
sub process_theatre {
    my ($self, $theatreID, $listings) = @_;

    my $theatre = &tnmc::movies::theatres::get_theatre($theatreID);
    print "$theatre->{name}\n";

    foreach my $listing (@$listings) {
        print "\t", $listing->{cinemaclockID}, "\t", $listing->{title}, " ";

        ## find movie
        my $movie = $self->get_or_create_movie($listing);

        ## update attributes
        $movie->{cinemaclockID}   = $listing->{cinemaclockID};
        $movie->{cinemaclockPage} = $listing->{page};
        $movie->{statusShowing}   = 1;
        $movie->{title}           = $listing->{title};
        &tnmc::movies::movie::set_movie($movie);

        ## update showtimes
        $self->add_showtime($theatreID, $movie->{movieID});

        print "\n";
    }
}

1;
