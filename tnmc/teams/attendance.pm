##################################################################
#	Scott Thompson (mar 2003)
##################################################################

package tnmc::teams::attendance;

use tnmc;

#
# vars
#

use vars qw(%type);

%type = (
    "yes"   => "Yes",
    "late"  => "Late",
    "early" => "Leave Early",
    "maybe" => "Maybe",
    "no"    => "No",
    "undef" => "--"
);

my @keys  = ("meetID", "userID");
my $table = 'TeamMeetAttendance';

#
# subs (basic)
#

sub new_attendance {

    # usage: &new_attendance();
    return &tnmc::db::link::newLink($table, \@keys);
}

sub set_attendance {

    # usage: &set_attendance($attendance_hash);
    return &tnmc::db::link::replaceLink($table, \@keys, $_[0]);
}

sub get_attendance {

    # usage: &get_attendance($meetID, $userID);
    my %hash = (
        "meetID" => $_[0],
        "userID" => $_[1]
    );
    return &tnmc::db::link::getLink($table, \@keys, \%hash);
}

sub del_attendance {

    # usage: &del_attendance($meetID, $userID);
    my %hash = (
        "meetID" => $_[0],
        "userID" => $_[1]
    );
    return &tnmc::db::link::delLink($table, \@keys, \%hash);
}

sub list_users {

    # usage: &list_users($meetID);
    return &tnmc::db::link::listLinks($table, "userID", "WHERE meetID = $_[0]");
}

sub list_meets {

    # usage: &list_meets($userID);
    return &tnmc::db::link::listLinks($table, "meetID", "WHERE userID = $_[0]");
}

# keepin perl happy...
return 1;

