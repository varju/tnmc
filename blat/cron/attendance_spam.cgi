#!/usr/bin/perl
##################################################################
#	Scott Thompson - scottt@css.sfu.ca (nov/98)
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use warnings;

use CGI;

use lib "..";
use lib::db;
use lib::blat;
use lib::date;
use lib::email;

&attendance_spam();

sub attendance_spam {

    my @all_players    = &lib::blat::list_players();
    my @upcoming_games = &lib::blat::get_upcoming_gameids();
    my $gameid         = @upcoming_games[0];
    my @bad_players;
    my $game = &lib::blat::get_game($gameid);
    print %$game, "\n";
    foreach my $playerid (@all_players) {
        my $attendance = &lib::blat::player_is_coming_to_game($playerid, $gameid);
        if (!$attendance) {
            push @bad_players, $playerid;
        }
    }

    foreach my $playerid (@bad_players) {
        my $player = &lib::blat::get_player($playerid);
        print "$playerid - $player->{name}\n";
        push @cc_list, "\"$player->{name}\" <$player->{email}>";
    }
    my $cc_list = join(", ", @cc_list);

    my $message = "Hey!\n\nAre you coming to the next ulti game?\n\n";

    my %message = (
        'To:'      => "scottt\@interchange.ubc.ca",
        'From:'    => "scottt\@interchange.ubc.ca",
        'Cc:'      => $cc_list,
        'Subject:' => "Blat reminder",
        'Body'     => $message
    );

    &lib::email::send_email(\%message);

}

