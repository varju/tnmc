#!/usr/bin/perl

use strict;
use warnings;

use lib '/tnmc';
use tnmc::updater::google;

use Test::Simple tests => 61;

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
ok_movie(shift(@$showtimes), 'Teen Tales', '317f954ebb7317f1', '');
ok_movie(shift(@$showtimes), 'This Ain\'t California', 'cd7cdec0a8f3227a', '');
ok_movie(shift(@$showtimes), 'All Apologies (Ai de tishen)', '15f8d5bce827efd', '');
ok_movie(shift(@$showtimes), 'As Luck Would Have It (La chispa de la vida)', 'cee951b85aee370a', '');
ok_movie(shift(@$showtimes), 'Call Me Kuchu', '7636b5a8ef30f499', '');
ok_movie(shift(@$showtimes), 'Camel Caravan', 'd6c46ad0afa69439', '');
ok_movie(shift(@$showtimes), 'Design of Death (Sha sheng)', '5ea45862ded50271', '');
ok_movie(shift(@$showtimes), 'Dreams for Sale (Yume uru futari)', '69f5eb38c01fac91', '');
ok_movie(shift(@$showtimes), 'East Meets West', '50c4feb30c2a89b5', '');
ok_movie(shift(@$showtimes), 'Far From Afghanistan', '9dbee03dfda30289', '');
ok_movie(shift(@$showtimes), 'In Another Country (Da-Reun Na-Ra-e-Suh)', '6915a85bbda37f07', '');
ok_movie(shift(@$showtimes), 'Jai Bhim Comrade', '22e83e12b6e8110c', '');
ok_movie(shift(@$showtimes), 'Key of Life (Kagidorobou no method)', 'fd56537230075c03', '');
ok_movie(shift(@$showtimes), 'La demora', '584aed50329fafc2', '');
ok_movie(shift(@$showtimes), 'Raising Resistance', '8acc3a0ee1016356', '');
ok_movie(shift(@$showtimes), 'Reconversao', '8d9b91858a2fe37b', '');
ok_movie(shift(@$showtimes), 'Teddy Bear (10 timer til paradis)', '9ac42106072e93c8', '');
ok_movie(shift(@$showtimes), 'The Last Friday (Al juma al kheira)', '337e8e5c2e9adf35', '');
ok_movie(shift(@$showtimes), 'The Last White Knight', '62a7a992d61e22bf', '');
ok_movie(shift(@$showtimes), 'Things Left Behind', '433d512ab76c9482', '');
ok_movie(shift(@$showtimes), 'When Night Falls', '79c5e339fd2908f2', '');

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
