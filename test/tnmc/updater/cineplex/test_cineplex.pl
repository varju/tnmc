#!/usr/bin/perl

use strict;
use warnings;

use lib '/tnmc';
use tnmc::updater::cineplex;

use Test::Simple tests => 13;

my $body = read_file('theatre.html');

my $updater = tnmc::updater::cineplex->new();

my $tue = $updater->get_next_tuesday();
print "$tue\n";

# my $showtimes = $updater->get_theatre_showtimes('scotiabank-theatre-vancouver');
my $showtimes = $updater->parse_theatre_showtimes($body);

ok_movie(shift(@$showtimes), 'Doctor Strange', 'doctor-strange', '');
ok_movie(shift(@$showtimes), 'Arrival', 'arrival-2016', '');
ok_movie(shift(@$showtimes), 'Hacksaw Ridge', 'hacksaw-ridge', '');
ok_movie(shift(@$showtimes), 'Inferno', 'inferno-2016', '');
ok_movie(shift(@$showtimes), 'Jack Reacher: Never Go Back', 'jack-reacher-never-go-back', '');
ok_movie(shift(@$showtimes), 'The Accountant', 'the-accountant-2016', '');

ok(0 == scalar(@$showtimes));

sub read_file {
    my ($filename) = @_;
    open(my $fh, $filename);
    local($/) = undef;
    my $body = <$fh>;
    close($fh);
    return $body;
}

sub ok_movie {
    my ($listing, $title, $cineplexID, $page) = @_;

    ok($title eq $listing->{title}, "Title: \"$title\" eq \"" . $listing->{title} . "\"");
    ok($cineplexID eq $listing->{cineplexID}, "- cineplexID: $cineplexID eq " . $listing->{cineplexID});
    #ok($page eq $listing->{page}, "- Page: $page eq " . $listing->{page});
}
