#!/usr/bin/perl

use warnings;

use lib '/tnmc';
use tnmc;

#
# common variables
#

&tnmc::teams::htmlTemplate::change_template();

my @options = (
    { "key" => "yes",   "val" => "Yes" },
    { "key" => "late",  "val" => "Late" },
    { "key" => "early", "val" => "Leave Early" },
    { "key" => "maybe", "val" => "Maybe" },
    { "key" => "no",    "val" => "No" },
    { "key" => "undef", "val" => "--" }
);

my $script_name = "teams/attendance_mod.cgi";

#
# Actions
#

my $ACTION = lc(&tnmc::cgi::param("ACTION"));

if ($ACTION eq 'player') {
    &action_player();
}
elsif ($ACTION eq 'meet') {
    &action_meet();
}
elsif ($ACTION eq 'playersubmit') {
    &action_player_submit();
}
else {
    &action_player();
}

#
# Action Subs
#

sub action_player {

    require tnmc::user;
    require tnmc::teams::meet;
    require tnmc::teams::team;
    require tnmc::teams::roster;
    require tnmc::util::date;

    # setup
    my $teamID = &tnmc::cgi::param("teamID");
    my $userID = &tnmc::cgi::param("userID");
    my $team   = &tnmc::teams::team::get_team($teamID);
    my $user   = &tnmc::user::get_user($userID);
    my $roster = &tnmc::teams::roster::get_roster($teamID, $userID);
    my @meets  = &tnmc::teams::meet::find_meets("WHERE teamID = '$teamID' ORDER BY date");

    # show the page
    &tnmc::template::header();

    &tnmc::template::show_heading("$user->{username}\'s attendance for $team->{name}");
    print qq{
	<form action="$script_name" method="post">
	<input type="hidden" name="ACTION" value="playerSubmit">
	<input type="hidden" name="teamID" value="$teamID">
	<table>
    };
    foreach my $meetID (@meets) {
        my $attendance = &tnmc::teams::attendance::get_attendance($meetID, $userID);
        my $meet       = &tnmc::teams::meet::get_meet_extended($meetID);
        my $key        = "type-$meetID-$userID";
        my $type       = $attendance->{type} || 'undef';
        my $date       = &tnmc::util::date::format('day_time', $meet->{"date"});
        my $lastmod    = &tnmc::util::date::format('mysql',    $meet->{"date"});
        my $player_shortage =
          ($meet->{limits}->{T} || $meet->{limits}->{ $roster->{gender} });
        my $no_edit = ($meet->{limits}->{time});

        my $player_shortage_warning;
        if ($player_shortage) {
            $player_shortage_warning = "<b>$meet->{totals}->{M}->{yes}/$meet->{totals}->{F}->{yes}</b>";
        }

        my $font = ($meet->{limits}->{time}) ? "<font color=777777>" : "";
        print qq{
	    <tr><td>$font$date</td>
		<td>$font$meet->{type}</td>
		<td>$font$meet->{location}</td>
	};

        if ($no_edit) {
            print qq{
		<td>$font$tnmc::teams::attendance::type{$type}
		<input type=hidden name="$key" value="$type">
		</td>
		</tr>
	    };
        }
        else {
            print qq{
		<td $bgcolor><select name="$key">
	    };
            foreach my $option (@options) {
                my $selected = ($option->{key} eq $type) ? "selected" : "";
                print qq{<option $selected value="$option->{key}">$option->{val}</option>};
            }
            print qq{
		</select>
		$player_shortage_warning
		</td>
	        <td><!-- lastmod: $lastmod --></td>
		</tr>
	    };
        }

    }
    print qq{
	</table>
	<input type="submit" value="Save">
    };

    &tnmc::template::footer();
}

sub action_meet {

    require tnmc::user;
    require tnmc::teams::meet;
    require tnmc::teams::team;
    require tnmc::teams::roster;
    require tnmc::util::date;

    # setup
    my $meetID  = &tnmc::cgi::param("meetID");
    my $meet    = &tnmc::teams::meet::get_meet_extended($meetID);
    my $teamID  = $meet->{teamID};
    my $team    = &tnmc::teams::team::get_team($teamID);
    my @players = &tnmc::teams::roster::list_users($teamID);
    @players = sort tnmc::user::by_username (@players);

    # show the page
    &tnmc::template::header();

    &tnmc::template::show_heading("$meet->{date} $meet->{type} attendance for $team->{name}");
    print qq{
	<form action="$script_name" method="post">
	<input type="hidden" name="ACTION" value="playerSubmit">
	<input type="hidden" name="teamID" value="$teamID">
	<table>
    };
    foreach my $userID (@players) {
        my $user       = &tnmc::user::get_user($userID);
        my $roster     = &tnmc::teams::roster::get_roster($teamID, $userID);
        my $attendance = &tnmc::teams::attendance::get_attendance($meetID, $userID);
        my $key        = "type-$meetID-$userID";
        my $type       = $attendance->{type} || 'undef';
        my $no_edit    = ($meet->{limits}->{time});

        print qq{
	    <tr><td>$user->{username}</td>
		<td>$roster->{gender}</td>
		<td>$roster->{status}</td>
	    };
        if ($no_edit) {
            print qq{
		<td>$tnmc::teams::attendance::type{$type}
		    <input type=hidden name="$key" value="$type">
		</td>
	    };
        }
        else {
            print qq{
		<td><select name="$key">
	    };
            foreach my $option (@options) {
                my $selected = ($option->{key} eq $type) ? "selected" : "";
                print qq{<option $selected value="$option->{key}">$option->{val}</option>};
            }
            print qq{
		</select>
		    </td>
	    };
        }
        print qq{
	    </tr>
	};
    }
    print qq{
	</table>
	<input type="submit" value="Save">
    };

    &tnmc::template::footer();
}

sub action_player_submit {

    require tnmc::cgi;
    require tnmc::teams::attendance;

    # load data
    my $teamID = &tnmc::cgi::param("teamID");

    my @params = &tnmc::cgi::param();

    foreach my $param (@params) {
        my ($key, $meetID, $userID) = split("-", $param);

        next if ($key ne 'type');

        my $val        = &tnmc::cgi::param($param);
        my $attendance = &tnmc::teams::attendance::get_attendance($meetID, $userID);

        # does not exist: make a new attendance
        if (!$attendance) {
            $attendance           = &tnmc::teams::attendance::new_attendance();
            $attendance->{meetID} = $meetID;
            $attendance->{userID} = $userID;
        }

        # attendance changed: save to db
        if ($attendance->{type} ne $val) {

            # player bailing?
            if ($attendance->{type} eq 'yes') {

                # low on players?
                my $meet   = &tnmc::teams::meet::get_meet_extended($meetID);
                my $roster = &tnmc::teams::roster::get_roster($meet->{teamID}, $userID);

                if ($meet->{limits}->{T} || $meet->{limits}->{ $roster->{gender} }) {

                    # send email to team

                    my $user = &tnmc::user::get_user($userID);
                    my $team = &tnmc::teams::team::get_team($meet->{teamID});
                    $meet->{totals}->{ $roster->{gender} }->{yes}--;    ## fudge the numbers
                        # $meet->{players_text} =~ s/\b$user->{username} //; ## fudge the users

                    my $subject =
"No $user->{username} on $meet->{date_text} ($meet->{totals}->{M}->{yes}/$meet->{totals}->{F}->{yes})";
                    my $body =
"\n\n$user->{username}\'s attendance was changed from yes to $val.\n\nThe roster for $meet->{date_text} now has $meet->{totals}->{M}->{yes} guys, $meet->{totals}->{F}->{yes} girls.\n\n";

                    my %headers = (
                        'To'      => $team->{emailList},
                        'From'    => $team->{emailList},
                        'Subject' => $subject,
                    );
                    &tnmc::mail::send::message_send(\%headers, $body);

                }
            }

            # save to db
            $attendance->{type}      = $val;
            $attendance->{timestamp} = undef();
            &tnmc::teams::attendance::set_attendance($attendance);

        }

    }

    print "Location: team.cgi?teamID=$teamID\n\n";
}

