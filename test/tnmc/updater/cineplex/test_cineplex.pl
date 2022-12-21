#!/usr/bin/perl

use strict;
use warnings;

use lib '/tnmc';
use tnmc::updater::cineplex;
use utf8;
use Test::Simple tests => 25;

my $body = read_file('theatre.html');

my $updater = tnmc::updater::cineplex->new();

my $tue = $updater->get_next_tuesday();
print "$tue\n";

# my $showtimes = $updater->get_theatre_showtimes('scotiabank-theatre-vancouver');
my $showtimes = $updater->parse_theatre_showtimes($body);

ok_movie(shift(@$showtimes), "Empire of Light",'empire-of-light','');
ok_movie(shift(@$showtimes), "Strange World",'strange-world','');
ok_movie(shift(@$showtimes), "Spoiler Alert",'spoiler-alert','');
ok_movie(shift(@$showtimes), "Top Gun: Maverick",'top-gun-maverick','');
ok_movie(shift(@$showtimes), "Devotion",'devotion','');
ok_movie(shift(@$showtimes), "Bones and All",'bones-and-all','');
ok_movie(shift(@$showtimes), "The Menu",'the-menu','');
ok_movie(shift(@$showtimes), "The Banshees of Inisherin",'the-banshees-of-inisherin','');
ok_movie(shift(@$showtimes), "TÁR",'tar','');
ok_movie(shift(@$showtimes), "PLAN A",'plan-a','');
ok_movie(shift(@$showtimes), "Roald Dahl’s Matilda The Musical",'roald-dahls-matilda-the-musical','');
ok_movie(shift(@$showtimes), "Guillermo Del Toro's Pinocchio",'guillermo-del-toros-pinocchio','');

ok(0 == scalar(@$showtimes));

sub read_file {
    my ($filename) = @_;
    open(my $fh, $filename);
    local ($/) = undef;
    my $body = <$fh>;
    close($fh);
    return $body;
}

sub ok_movie {
    my ($listing, $title, $cineplexID, $page) = @_;

    ok($title eq $listing->{title},           "Title: \"$title\" eq \"" . $listing->{title} . "\"");
    ok($cineplexID eq $listing->{cineplexID}, "- cineplexID: $cineplexID eq " . $listing->{cineplexID});

    #ok($page eq $listing->{page}, "- Page: $page eq " . $listing->{page});
}
