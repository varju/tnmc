package tnmc::homepage::teams;

use strict;
use tnmc;

#
# module configuration
#

#
# module vars
#

#
# module routines
#

sub show {

    if ($tnmc::security::auth::USERID) {
        &show_team_info();
    }
    else {
        &show_team_info_ANON();
    }
}

sub show_team_info_ANON {

    my @active_teams =
      &tnmc::teams::team::list_teams("WHERE seasonStart < NOW() AND seasonEnd > NOW() ORDER BY seasonStart");

    if (scalar @active_teams) {
        &tnmc::template::show_heading("Teams");

        map { &tnmc::teams::template::show_team($_, 'tiny'); } @active_teams;
    }
}

sub show_team_info {

    my $userID = $tnmc::security::auth::USERID;

    my @active_teams =
      &tnmc::teams::team::list_teams("WHERE seasonStart < NOW() AND seasonEnd > NOW() ORDER BY seasonStart");

    # no active teams
    return if (!scalar @active_teams);

    my @user_teams;
    foreach my $teamID (@active_teams) {
        my $roster = &tnmc::teams::roster::get_roster($teamID, $userID);
        next if (!$roster);
        push @user_teams, $teamID;
    }

    # not in any active teams
    return if (!scalar @user_teams);

    &tnmc::template::show_heading("Teams");

    map { &tnmc::teams::template::show_team($_, 'tiny'); } @user_teams;

}

1;
