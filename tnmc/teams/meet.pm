##################################################################
#	Scott Thompson (mar 2003)
##################################################################

package tnmc::teams::meet;

use tnmc;

#
# vars
#

use vars qw(%types);

@types = ("Game",
	  "Practice",
	  "Tournament",
	  "Party",
	  "Games Night",
	  "Canceled",
          "(none)",
	  );

$table = 'TeamMeets';
$key = 'meetID';

#
# Meet
#

sub new_meet{
    # usage: my $meet_hash = &new_meet();
    return &tnmc::db::item::newItem($table, $key);
}

sub add_meet{
    # usage: &add_meet($meet_hash);
    return &tnmc::db::item::addItem($table, $key, $_[0]);
}

sub get_meet{
    # usage: my $meet_hash = &get_meet($meetID);
    return &tnmc::db::item::getItem($table, $key, $_[0]);
}

sub set_meet{
    # usage: &set_meet($meet_hash);
    return &tnmc::db::item::replaceItem($table, $key, $_[0]);
}

sub del_meet{
    # usage: &del_meet($meetID)
    return &tnmc::db::item::delItem($table, $key, $_[0]);
}

sub list_meets{
    # usage: &list_meets($teamID)
    return &tnmc::db::item::listItems($table, $key, "WHERE teamID = $_[0]");
}

sub find_meets{
    # usage: &find_meets("WHERE condition = true ORDER BY column")
    return &tnmc::db::item::listItems($table, $key, $_[0]);
}

#
# Special Subs
#

sub get_meet_extended{
    my ($meetID) = @_;
    my $meet = &tnmc::teams::meet::get_meet($meetID);
    my $teamID = $meet->{teamID};
    my @players = &tnmc::teams::roster::list_users($teamID);
    @players = sort tnmc::user::by_username @players;
    
    
    $meet->{date_text} = &tnmc::util::date::format('day_time', $meet->{date});
    $meet->{totals}->{M} = {'yes', 0, 'maybe', 0, 'no', 0, 'late', 0};
    $meet->{totals}->{F} = {'yes', 0, 'maybe', 0, 'no', 0, 'late', 0};
    $meet->{players_text} = '';
    
    foreach my $userID (@players){
	
	my $attendance = &tnmc::teams::attendance::get_attendance($meetID, $userID);
	my $type = $attendance->{type};
	my $player = tnmc::user::get_user($userID);
	my $roster = &tnmc::teams::roster::get_roster($teamID, $userID);
	$meet->{totals}->{$roster->{gender}}->{$type} ++;
	
	if ($type eq "yes"){
	    $meet->{players_text} .= "$player->{username} ";
	}
    }
    
    $meet->{totals}->{M}->{not_yes} = 0
	+ $meet->{totals}->{M}->{no} 
        + $meet->{totals}->{M}->{maybe}
        + $meet->{totals}->{M}->{late};

    $meet->{totals}->{F}->{not_yes} = 0
	+ $meet->{totals}->{F}->{no} 
        + $meet->{totals}->{F}->{maybe}
        + $meet->{totals}->{F}->{late};

    $meet->{totals}->{X}->{yes} = 0 
	+ $meet->{totals}->{M}->{yes}
        + $meet->{totals}->{F}->{yes};
    
    $meet->{action}->{edit} = "teams/meet_mod.cgi?ACTION=edit&meetID=$meetID";
    $meet->{action}->{roster} = "teams/attendance_mod.cgi?ACTION=meet&meetID=$meetID";
    
    return $meet;
}

sub remove_meet{
    my ($meetID) = @_;
    
    my $dbh = tnmc::db::db_connect();
    
    # remove attendance
    $dbh->do("DELETE FROM TeamMeetAttendance WHERE meetID = $meetID");
    
    # remove meet
    &del_meet($meetID);
}

# keepin perl happy...
return 1;










