package tnmc::updater::google;

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use HTML::TreeBuilder::XPath;

use tnmc::general_config;
use tnmc::movies::movie;
use tnmc::updater::base;

use vars qw(@ISA);
@ISA = ("tnmc::updater::base");

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new();
    bless($self, $class);
    return $self;
}

sub get_label
{
    my ($self) = @_;
    return 'GOOGLE';
}

sub get_type
{
    my ($self) = @_;
    return 'googleID';
}

sub get_theatre_showtimes
{
    my ($self, $googleID) = @_;
    
    ## get webpage
    my $ua = $self->get_valid_ua();
    my $URL = "http://www.google.com/movies?tid=$googleID";
    print "DEBUG: Requesting $URL\n";
    my $req = new HTTP::Request GET => $URL;
    my $res = $ua->request($req);
    my $text = $res->content;

    return $self->parse_theatre_showtimes($text);
}

sub parse_theatre_showtimes
{
    my ($self, $text) = @_;

    my $tree = HTML::TreeBuilder::XPath->new_from_content($text);
    #print "tree: $tree\n";

    my $movie_divs = $tree->findnodes( qq{//div[\@class="movie"]} );
    #print "movie_divs: $movie_divs\n";


    my @movies;

    foreach my $movie_div ($movie_divs->get_nodelist())
    {
	#print "movie_div $movie_div\n";

	#my @children = $movie_div->content_list;
	#print "children: @children\n";

	my $name_div = get_child($movie_div, 0, 'div', { 'class', 'name' });
	my $name_anchor = get_child($name_div, 0, 'a');
	my $movieid = parse_movie_href($name_anchor->attr('href'));
	#print "- href: ", $name_anchor->attr('href'), ", movieid=", $movieid, "\n";

	my $name_span = get_child($name_anchor, 0, 'span');
	my $title = parse_title($name_span->as_text());
	#print "- title: ", $title, "\n";

	#my $times_div = get_child($movie_div, 2, 'div', { 'class', 'times' });
	#my $times = $times_div->as_text();
	#print "- times: ", $times, "\n";

	my %movie = ( "googleID" => $movieid, "title" => $title, 'page' => '' );
	push @movies, \%movie;
    }

    $tree->delete();

    return \@movies;
}

sub get_child
{
    my ($element, $child_index, $expected_tag, $assert_attrs) = @_;

    my @children = $element->content_list();
    my $child = $children[$child_index];
    die "couldn't find child" if !defined($child);
    
    if (!defined($assert_attrs)) {
	$assert_attrs = {};
    }

    $assert_attrs->{'_tag'} = $expected_tag;
    foreach my $key (keys %$assert_attrs)
    {
	my $expected_val = $assert_attrs->{$key};
	die "Wrong value for $key" unless $child->attr($key) eq $expected_val;
    }

    return $child;
}

sub parse_movie_href
{
    my ($href) = @_;

    if ($href =~ /&mid=(\w+)/) {
	return $1;
    }
    die "Can't parse href $href\n";
}

sub parse_title
{
    my ($title) = @_;

    return &tnmc::movies::movie::reformat_title($title);
}

sub add_movie
{
    my ($self, $movies, $googleID, $page, $title) = @_;

    my $pretty_title = &tnmc::movies::movie::reformat_title($title);
    my %movie = ( "googleID" => $googleID, "page" => $page, "title" => $pretty_title );
    push @$movies, \%movie;
}


## sets new showtimes
sub process_theatre
{
    my ($self, $theatreID, $listings) = @_;

    my $theatre = &tnmc::movies::theatres::get_theatre($theatreID);
    print "$theatre->{name}\n";

    foreach my $listing (@$listings) {
	print "\t", $listing->{googleID}, "\t", $listing->{title}, " ";

	## find movie
	my $movie = $self->get_or_create_movie($listing);

	## update attributes
	$movie->{googleID} = $listing->{googleID};
	$movie->{statusShowing} = 1;
	$movie->{title} = $listing->{title};
	&tnmc::movies::movie::set_movie($movie);

	## update showtimes
	$self->add_showtime($theatreID, $movie->{movieID});
	
	print "\n";
    }
}

1;
