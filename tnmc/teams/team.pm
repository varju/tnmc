##################################################################
#	Scott Thompson (mar 2003)
##################################################################

package tnmc::teams::team;

use tnmc;

#
# vars
#

use vars qw(%sports);

%sports = qw(ulti Ultimate
	     vball Volleyball
	     hockey Hockey
	     none (none) );

my $table = 'Teams';
my $key = 'teamID';


#
# Team
#

sub new_team{
    # usage: my $team_hash = &new_team();
    return &tnmc::db::item::newItem($table, $key);
}

sub add_team{
    # usage: &add_team($team_hash);
    return &tnmc::db::item::addItem($table, $key, $_[0]);
}

sub get_team{
    # usage: my $team_hash = &get_team($teamID);
    return &tnmc::db::item::getItem($table, $key, $_[0]);
}

sub set_team{
    # usage: &set_team($team_hash);
    return &tnmc::db::item::replaceItem($table, $key, $_[0]);
}

sub del_team{
    # usage: &del_team($teamID)
    return &tnmc::db::item::delItem($table, $key, $_[0]);
}

sub list_teams{
    # usage: &list_teams("WHERE condition = true ORDER BY column")
    return &tnmc::db::item::listItems($table, $key, $_[0]);
}

#
# special subs
#

sub get_team_extended{
    my ($teamID) = @_;
    
    my $team = &get_team($teamID);
    
    
    ## actions
    $team->{action}->{view} = "teams/team.cgi?teamID=$teamID";
    if (&USERID_is_admin($teamID)){
	$team->{action}->{edit} = "teams/team_mod.cgi?ACTION=edit&teamID=$teamID";
	$team->{action}->{del}  = "teams/team_mod.cgi?ACTION=del&teamID=$teamID";
    }
    
    return $team;
}

sub remove_team{
    my ($teamID) = @_;
    
    my $dbh = tnmc::db::db_connect();
    
    # remove attendance
    my @meets = &tnmc::teams::meet::list_meets($teamID);
    foreach my $meetID (@meets){
	$dbh->do("DELETE FROM TeamMeetAttendance WHERE meetID = $meetID");
    }
    
    # remove meets
    $dbh->do("DELETE FROM TeamMeets WHERE teamID = $teamID");
    
    # remove roster
    $dbh->do("DELETE FROM TeamRooster WHERE teamID = $teamID");
    
    # remove team
    &del_team($teamID);
}

sub USERID_is_admin{
    my ($teamID) = @_;
    
    my $userID = $tnmc::security::auth::USERID;
    
    # is captain
    my $team = &get_team($teamID);
    return 2 if ($team->{captainID} eq $userID);
    
    # is admin
    my $roster = &tnmc::teams::roster::get_roster($teamID, $userID);
    return 1 if ($roster->{is_admin} == 1);

    # nothing
    return 0
}


# keepin perl happy...
return 1;










