#!/usr/bin/perl

use strict;
use warnings;

use lib '/tnmc';
use tnmc::updater::google;

use Test::Simple tests => 21;

my $body = read_file('theatre.html');

my $updater = tnmc::updater::google->new();
my $showtimes = $updater->parse_theatre_showtimes($body);

ok_movie(shift(@$showtimes), 'A Respectable Family (Yek Khanevadeh-e Mohtaram)', 'c9df04bcc6552621', '');
ok_movie(shift(@$showtimes), 'Abu, Son of Adam (Adaminte Makan Abu)', '89d0dc27fbfb2380', '');
ok_movie(shift(@$showtimes), 'Bitter Seeds', '51e69169cc4d331', '');
ok_movie(shift(@$showtimes), 'Heart of Sky, Heart of Earth (Herz des Himmels, Herz der Erde)', 'b0d4207b73bd183e', '');
ok_movie(shift(@$showtimes), 'In Search of Blind Joe Death: The Saga of John Fahey', '9f7ea346276a9234', '');
ok_movie(shift(@$showtimes), 'Lore', '34134cfc8f93063e', '');
ok_movie(shift(@$showtimes), 'Neighbouring Sounds (O som ao redor)', '706b43f0ffbbdf9f', '');
ok_movie(shift(@$showtimes), 'Paradise: Love (Paradis: Liebe)', '1169b509d3ea4b2b', '');
ok_movie(shift(@$showtimes), 'Quando la notte', '3ef5fea316edd163', '');
ok_movie(shift(@$showtimes), '', '', '');

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
    my ($listing, $title, $googleID, $page) = @_;

    ok($title eq $listing->{title}, "Title: $title eq " . $listing->{title});
    ok($googleID eq $listing->{googleID}, "- googleID: $googleID eq " . $listing->{googleID});
    #ok($page eq $listing->{page}, "- Page: $page eq " . $listing->{page});
}
