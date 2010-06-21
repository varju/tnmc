#!/usr/bin/perl

use strict;
use warnings;

use lib '/tnmc';
use tnmc::updater::google;

use Test::Simple tests => 21;

my $body = read_file('tinseltown.html');

my $updater = tnmc::updater::google->new();
my $showtimes = $updater->parse_theatre_showtimes($body);

ok(10 == scalar(@$showtimes));
ok_movie(shift(@$showtimes), 'Toy Story 3 in Disney Digital 3D', '2b1743e27b89eee2', '');
ok_movie(shift(@$showtimes), 'Get Him to the Greek', '654b591075323417', '');
ok_movie(shift(@$showtimes), 'Jonah Hex', 'b50b817399c1f168', '');
ok_movie(shift(@$showtimes), 'Killers', '75157c2fe2862811', '');
ok_movie(shift(@$showtimes), 'Splice', 'dcc1fa3a575a65db', '');
ok_movie(shift(@$showtimes), 'Year of the Carnivore', '257bb700078750e1', '');
ok_movie(shift(@$showtimes), 'Agora', '80f244942c731186', '');
ok_movie(shift(@$showtimes), 'Toy Story 3', '582321b538bd65ba', '');
ok_movie(shift(@$showtimes), 'Harry Brown', 'ebf02d9cc22db7fe', '');
ok_movie(shift(@$showtimes), 'Exit Through the Gift Shop', '1ebaacde93f7265b', '');

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

    $title = &tnmc::movies::movie::reformat_title($title);

    ok($title eq $listing->{title}, "Title: $title eq " . $listing->{title});
    ok($googleID eq $listing->{googleID}, "- googleID: $googleID eq " . $listing->{googleID});
    #ok($page eq $listing->{page}, "- Page: $page eq " . $listing->{page});
}
