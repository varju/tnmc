#!/usr/bin/perl

use strict;
use warnings;

use lib '/tnmc';
use tnmc::updater::cinemaclock;

use Test::Simple tests => 46;

my $body = read_file('Tinseltown.html');
my $showtimes = tnmc::updater::cinemaclock::parse_theatre_showtimes($body);

ok(15 == scalar(@$showtimes));
ok_movie(shift(@$showtimes), 'The Ghost Writer', 36237, 'The_Ghost_Writer.html');
ok_movie(shift(@$showtimes), 'Chloe', 35869, 'Chloe.html');
ok_movie(shift(@$showtimes), 'How to Train Your Dragon', 13121, 'How_to_Train_Your_Dragon.html');
ok_movie(shift(@$showtimes), 'How to Train Your Dragon 3D', 13121, 'How_to_Train_Your_Dragon.html');
ok_movie(shift(@$showtimes), 'A Shine of Rainbows', 32985, 'A_Shine_of_Rainbows.html');
ok_movie(shift(@$showtimes), 'Death at a Funeral', 35720, 'Death_at_a_Funeral.html');
ok_movie(shift(@$showtimes), 'Shutter Island', 19234, 'Shutter_Island.html');
ok_movie(shift(@$showtimes), 'Oceans', 32781, 'Oceans.html');
ok_movie(shift(@$showtimes), 'Control Alt Delete', 38017, 'Control_Alt_Delete.html');
ok_movie(shift(@$showtimes), 'The Back-Up Plan', 31265, 'The_Back-Up_Plan.html');
ok_movie(shift(@$showtimes), 'The Losers', 35718, 'The_Losers.html');
ok_movie(shift(@$showtimes), 'Furry Vengeance', 35778, 'Furry_Vengeance.html');
ok_movie(shift(@$showtimes), 'Passenger Side', 33862, 'Passenger_Side.html');
ok_movie(shift(@$showtimes), 'The Secret in Their Eyes', 35573, 'The_Secret_in_Their_Eyes.html');
ok_movie(shift(@$showtimes), 'Kenny Chesney: Summer in 3D', 36968, 'Kenny_Chesney__Summer_in_3D.html');

sub read_file {
    my ($filename) = @_;
    open(my $fh, $filename);
    local($/) = undef;
    my $body = <$fh>;
    close($fh);
    return $body;
}

sub ok_movie {
    my ($listing, $title, $cinemaclockid, $page) = @_;

    $title = &tnmc::movies::movie::reformat_title($title);

    ok($title eq $listing->{title}, "Title: $title eq " . $listing->{title});
    ok($cinemaclockid eq $listing->{cinemaclockid}, "- CinemaclockId: $cinemaclockid eq " . $listing->{cinemaclockid});
    ok($page eq $listing->{page}, "- Page: $page eq " . $listing->{page});
}
