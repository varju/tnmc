package tnmc::updater::cineplex;

use strict;
use warnings;

use Carp qw(confess);
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use JSON;
use utf8;

use tnmc::general_config;
use tnmc::movies::movie;
use tnmc::updater::base;
use tnmc::util::date;

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
    return 'cineplex';
}

sub get_type {
    my ($self) = @_;
    return 'cineplexID';
}

sub get_theatre_showtimes {
    my ($self, $cineplexID) = @_;

    ## get webpage
    my $ua = $self->get_valid_ua();

    my $tues = &tnmc::util::date::get_next_tuesday();
    my $URL = "https://apis.cineplex.com/prod/cpx/theatrical/api/v1/showtimes?language=en&locationId=$cineplexID&date=$tues";

    print "DEBUG: Requesting $URL\n";
    my $header = ['Ocp-Apim-Subscription-Key' => 'dcdac5601d864addbc2675a2e96cb1f8'];
    my $req  = HTTP::Request->new('GET',$URL, $header);
    my $res  = $ua->request($req);
    my $text = $res->decoded_content;

    return $self->parse_theatre_showtimes($text);
}

sub parse_theatre_showtimes {
    my ($self, $text) = @_;

    my $tree = decode_json $text;
    my $movie_list = @$tree[0]->{dates}[0]->{movies};

    my @movies;
    foreach my $movie_entry (@$movie_list) {

        my $movieid = $movie_entry->{"filmUrl"};
        my $title = $movie_entry->{"name"};

        my %movie = ("cineplexID" => $movieid, "title" => $title, 'page' => '');
        push @movies, \%movie;
    }
    return \@movies;
}

sub parse_title {
    my ($title) = @_;

    return &tnmc::movies::movie::reformat_title($title);
}

sub add_movie {
    my ($self, $movies, $cineplexID, $page, $title) = @_;

    my $pretty_title = &tnmc::movies::movie::reformat_title($title);
    my %movie        = ("cineplexID" => $cineplexID, "page" => $page, "title" => $pretty_title);
    push @$movies, \%movie;
}

## sets new showtimes
sub process_theatre {
    my ($self, $theatreID, $listings) = @_;

    my $theatre = &tnmc::movies::theatres::get_theatre($theatreID);
    print "$theatre->{name}\n";

    foreach my $listing (@$listings) {
        print "\t", $listing->{cineplexID}, "\t", $listing->{title}, " ";

        ## find movie
        my $movie = $self->get_or_create_movie($listing);

        ## update attributes
        $movie->{cineplexID}    = $listing->{cineplexID};
        $movie->{statusShowing} = 1;
        $movie->{title}         = $listing->{title};
        &tnmc::movies::movie::set_movie($movie);

        ## update showtimes
        $self->add_showtime($theatreID, $movie->{movieID});

        print "\n";
    }
}

1;
