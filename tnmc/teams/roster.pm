##################################################################
#	Scott Thompson (mar 2003)
##################################################################

package tnmc::teams::roster;

use tnmc;


#
# vars
#

use vars qw(%status);

@status = ("Player",
	   "Sub",
	   "Cheerleader",
	   "(none)",
	   );

my @keys = ("teamID", "userID");
my $table = 'TeamRooster';

#
# subs (basic)
#

sub new_roster{
    # usage: &new_roster();
    return &tnmc::db::link::newLink($table, \@keys);
}

sub set_roster{
    # usage: &setRoster($roster_hash);
    return &tnmc::db::link::replaceLink($table, \@keys, $_[0]);
}

sub get_roster{
    # usage: &getRoster($teamID, $userID);
    my %hash = ("teamID" => $_[0],
                "userID" => $_[1]);
    return &tnmc::db::link::getLink($table, \@keys, \%hash);
}

sub del_roster{
    # usage: &delRoster($teamID, $userID);
    my %hash = ("teamID" => $_[0],
		"userID" => $_[1]);
    return &tnmc::db::link::delLink($table, \@keys, \%hash);
}

sub list_users{
    # usage: &listUsers($teamID);
    return &tnmc::db::link::listLinks($table, "userID", "WHERE teamID = $_[0]");
}

sub list_users_by_status{
    # usage: &listUsers($teamID, $status);
    return &tnmc::db::link::listLinks($table, "userID", "WHERE teamID = $_[0] AND status = '$_[1]'");
}

sub list_teams{
    # usage: &listTeams($userID);
    return &tnmc::db::link::listLinks($table, "teamID", "WHERE userID = $_[0]");
}


#
# special subs
#

sub remove_roster{
    my ($teamID, $userID) = @_;
    
    # remove attendance
    my @meets = &tnmc::teams::meet::list_meets($teamID);
    foreach my $meetID (@meets){
	&tnmc::teams::attendance::del_attendance($meetID, $userID);
    }
    
    # remove roster
    &del_roster($teamID, $userID);
}

# keepin perl happy...
return 1;










