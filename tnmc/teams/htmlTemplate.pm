##################################################################
#	Scott Thompson (mar 2003)
##################################################################

package tnmc::teams::htmlTemplate;

use tnmc;

#
# subs
#

sub change_template {
    my ($teamID) = @_;

    # teamID param
    if (!$teamID) {

        $teamID = &tnmc::cgi::param("teamID");
    }

    # meetID param
    if (!$teamID) {

        my $meetID = &tnmc::cgi::param("meetID");
        my $meet   = &tnmc::teams::meet::get_meet($meetID);
        $teamID = $meet->{teamID};
    }

    &set_team_template($teamID);
}

sub set_team_template {
    my ($teamID) = @_;

    return if !$teamID;

    my $team = &tnmc::teams::team::get_team($teamID);
    &tnmc::template::set_template($team->{htmlTemplate});
}

# keepin perl happy...
return 1;

