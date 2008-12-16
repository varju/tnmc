#!/usr/bin/perl

use strict;
use warnings;

use lib '/tnmc';
use tnmc::cinemaclock;

use Test::Simple tests => 22;

my $body = read_file('Scotiabank_Theatre_Vancouver.html');
my $showtimes = tnmc::cinemaclock::parse_theatre_showtimes($body);

ok(7 == scalar(@$showtimes));
ok_movie(shift(@$showtimes), 'Day the Earth Stood Still, The', 13325, 'The_Day_the_Earth_Stood_Still.html');
ok_movie(shift(@$showtimes), 'Milk', 19945, 'Milk.html');
ok_movie(shift(@$showtimes), 'Bolt', 13133, 'Bolt.html');
ok_movie(shift(@$showtimes), 'Twilight', 15869, 'Twilight.html');
ok_movie(shift(@$showtimes), 'Quantum of Solace', 13116, 'Quantum_of_Solace.html');
ok_movie(shift(@$showtimes), 'Role Models', 23059, 'Role_Models.html');
ok_movie(shift(@$showtimes), 'Body of Lies', 17480, 'Body_of_Lies.html');

sub read_file {
    my ($filename) = @_;
    open(my $fh, 'Scotiabank_Theatre_Vancouver.html');
    local($/) = undef;
    my $body = <$fh>;
    close($fh);
    return $body;
}

sub ok_movie {
    my ($listing, $title, $cinemaclockid, $page) = @_;

    ok($title eq $listing->{title}, "Title: $title eq " . $listing->{title});
    ok($cinemaclockid eq $listing->{cinemaclockid}, "CinemaclockId: $cinemaclockid eq " . $listing->{cinemaclockid});
    ok($page eq $listing->{page}, "Page: $page eq " . $listing->{page});
}
