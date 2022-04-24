package tnmc::updater::cineplex;

use strict;
use warnings;

use Carp qw(confess);
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use HTML::TreeBuilder::XPath;

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
    my $URL =
"http://www.cineplex.com/Showtimes/GetShowtimes?Location=$cineplexID&LocationUrl=$cineplexID&Latitude=49.2493221&Longitude=-123.1465862&RequestType=TheatreLookup&OutputType=showtimesonly&Date=$tues&PreviousDate=$tues&TimeFormat=12";

    print "DEBUG: Requesting $URL\n";
    my $req  = new HTTP::Request GET => $URL;
    my $res  = $ua->request($req);
    my $text = $res->content;

    return $self->parse_theatre_showtimes($text);
}

sub parse_theatre_showtimes {
    my ($self, $text) = @_;

    my $tree       = HTML::TreeBuilder::XPath->new_from_content($text);
    my $movie_divs = $tree->findnodes(qq{//a[\@class="movie-details-link-click"]});

    my @movies;
    foreach my $name_anchor ($movie_divs->get_nodelist()) {

        my $movieid = parse_movie_href($name_anchor->attr('href'));

        my $title = $name_anchor->as_text();
        $title =~ s/^\s+|\s+$//g;

        my %movie = ("cineplexID" => $movieid, "title" => $title, 'page' => '');
        push @movies, \%movie;
    }

    $tree->delete();

    return \@movies;
}

sub get_child {
    my ($element, $child_index, $expected_tag, $assert_attrs) = @_;

    my @children = $element->content_list();
    my $child    = $children[$child_index];
    confess "couldn't find child" if !defined($child);

    if (!defined($assert_attrs)) {
        $assert_attrs = {};
    }

    $assert_attrs->{'_tag'} = $expected_tag;
    foreach my $key (keys %$assert_attrs) {
        my $expected_val = $assert_attrs->{$key};
        my $actual_val   = $child->attr($key);
        if (!defined($child->attr($key))) {
            confess "Can't find attribute $key";
        }
        if ($child->attr($key) ne $expected_val) {
            confess "Wrong value for $key (was $actual_val, expected $expected_val)";
        }
    }

    return $child;
}

sub parse_movie_href {
    my ($href) = @_;

    if ($href =~ /\/Movie\/(.*)/) {
        return $1;
    }
    confess "Can't parse href $href\n";
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
