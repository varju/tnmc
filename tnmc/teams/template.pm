##################################################################
#	Scott Thompson (mar 2003)
##################################################################

package tnmc::teams::template;

use tnmc;


#
# vars
#

my $table = 'Teams';
my $key = 'teamID';

#
# Team
#

sub show_team{
    my ($teamID, $mode) = @_;
    
    #
    # mode: full, teampage
    # 
    
    my %show;
    if ($mode eq 'big'){
	$show{title} = 1;
	$show{desc} = 1;
	$show{season} = 1;
	$show{captain} = 1;
	$show{league} = 1;
	$show{meets} = 1;
	$show{actions} = 1;
    }
    if ($mode eq 'teampage'){
	$show{title} = 1;
	$show{desc} = 1;
	$show{league} = 1;
	$show{actions} = 1;
    }
    if ($mode eq 'tiny'){
	$show{title} = 1;
	$show{desc} = 1;
	$show{meets} = 1;
    }
    
    #
    # get team
    #
    
    my $team = &tnmc::teams::team::get_team_extended($teamID);
    
    my $season_start = &tnmc::util::date::format('short_date', $team->{seasonStart});
    my $season_end = &tnmc::util::date::format('short_date', $team->{seasonEnd});
    my $sport = $tnmc::teams::team::sports{$team->{sport}};
    my $captain = &tnmc::user::get_user($team->{captainID});
    my @meets = &tnmc::teams::meet::find_meets("WHERE teamID = $teamID AND TO_DAYS(date) >= TO_DAYS(NOW()) AND date < DATE_ADD(NOW(), INTERVAL 7 DAY) ORDER BY date");
    
    # show team
    
    print qq{
	<table border=0 cellspacing=0 cellpadding=1 width=100%>
		};
    print qq{
	    <tr><th colspan=2><a href="$team->{action}->{view}">$team->{name}</a> $sport</th></tr>
		} if $show{title};
    print qq{
	    <tr><td colspan=2>$team->{description}</td></tr>
		} if $show{desc};
    print qq{
	    <tr><td><b>Season</b></td>
		<td nowrap>$season_start - $season_end ($team->{seasonTimeSlot}) </td></tr>
		} if $show{season};
    print qq{
	    <tr><td><b>Captain</b></td>
		<td nowrap>$captain->{fullname} </td></tr>
		} if ($show{captain});
    print qq{
	    <tr><td><b>League</b></td>
		<td nowrap><a href="$team->{leagueURL}">$team->{leagueURL}</a></td></tr>
		} if ($team->{leagueURL} && $show{league});
    print qq{
	    <tr><td></td>
		<td nowrap><a href="$team->{leagueScheduleURL}">League Schedule</a></td></tr>
		} if ($team->{leagueScheduleURL} && $show{league});
    if ($show{actions}){
	
	print qq{
	    <tr><td><b>Actions</b></td>
		<td>
		};
	foreach my $action (keys %{$team->{action}}){
	    print qq{<a href="$team->{action}->{$action}">[$action]</a>
		 };
	}
	print qq{
		</td></tr>
		};
    }
    if ($show{meets}){
	foreach my $meetID (@meets){
	    my $Meet = &tnmc::teams::meet::get_meet_extended($meetID);
	    my $day = &tnmc::util::date::format("short_wday", $Meet->{date});
	    my $time = &tnmc::util::date::format("time", $Meet->{date});
	    print qq{
		<tr valign="top"><td nowrap><b>$day</b><br>
		    $Meet->{totals}->{X}->{yes}
			($Meet->{totals}->{M}->{yes}/$Meet->{totals}->{F}->{yes}) 

		</td>
		<td>$Meet->{type} at $Meet->{location} ($time)<br>
		    $Meet->{players_text}<br>
		    </td>
		</tr>
	    };
	}
    }
    print qq{
	</table>
	<br>
    };
}


sub show_team_schedule{
    my ($teamID) = @_;
    
    &tnmc::template::show_heading("Schedule");
    
    # get data
    my @meets = &tnmc::teams::meet::list_meets($teamID);
    my @players = &tnmc::teams::roster::list_users($teamID);
    
    # start up
    print qq{
	<table border=0 cellspacing=0 width=100%>
	<tr>
	    <th>Date</th>
	    <th>Location</th>
	    <th>&nbsp</th>
	    <th>M</th>
	    <th>F</th>
	    <th>Players</th>
	    </tr>
    };
    
    foreach my $meetID (@meets){
	my $Meet = &tnmc::teams::meet::get_meet_extended($meetID);
	
        print qq{
	    <tr valign="top">
		<td nowrap><a href="$Meet->{action}->{edit}"><b>$Meet->{date_text}</b></a></td>
		<td nowrap>$Meet->{type} @ $Meet->{location}</td>
		<td nowrap><b>$Meet->{totals}->{X}->{yes}</b></td>
		<td nowrap>$Meet->{totals}->{M}->{yes}-$Meet->{totals}->{M}->{not_yes}</td>
		<td nowrap>$Meet->{totals}->{F}->{yes}-$Meet->{totals}->{F}->{not_yes}</td>
		<td>$Meet->{players_text}</td>
	    </tr>
	};

    }
    
    print qq{
	<tr><td nowrap>
	    [<a href="teams/meet_mod.cgi?ACTION=add&teamID=$teamID">add game</a>]
	    </td></tr>
	</table>
	<br>
    };
    
}

sub show_team_roster{
    my ($teamID) = @_;
    
    &tnmc::template::show_heading("Roster");
    
    # get data
    my @meets = &tnmc::teams::meet::find_meets("WHERE teamID = $teamID ORDER BY date LIMIT 3");
    my @players = &tnmc::teams::roster::list_users($teamID);
    @players = sort tnmc::user::by_username @players;

    
    print qq{
	<table border=0 cellspacing=0 width=100%>
	<tr>
	    <th nowrap>Name</th>
	    <th nowrap>Phone</th>
    };
    foreach my $meetID (@meets){
        my $meet = &tnmc::teams::meet::get_meet($meetID);
        my $game_date = &tnmc::util::date::format('short_month_day', $meet->{"date"}) ;
        print "<th nowrap>$game_date</th>";
    }
    print "<th></th></tr>\n";
    foreach my $userID (@players){
	
	my $user = &tnmc::user::get_user($userID);
	my $roster = &tnmc::teams::roster::get_roster($teamID, $userID);
	my $phone = $user->{"phone$user->{phonePrimary}"};
        print qq{
            <tr>
		<td nowrap><a href="teams/roster_mod.cgi?ACTION=edit&teamID=$teamID&userID=$userID">$user->{username}</a></td>
		<td nowrap>$phone</td>
        };
        foreach $meetID (@meets){
            my $attendance = &tnmc::teams::attendance::get_attendance($meetID, $userID);
	    my $type = $tnmc::teams::attendance::type{$attendance->{type}};
	    if ($attendance->{type} eq 'yes' || $attendance->{type} eq 'late'){
		print "<td><b>$type</b></td>\n";
	    }else{
		print "<td>$type</td>\n";
	    }
		
        }
        print qq{
            <td nowrap>
		[<a href="teams/attendance_mod.cgi?ACTION=player&teamID=$teamID&userID=$userID">games</a>]
		[<a href="people/user_view.cgi?&userID=$userID">info</a>]
		</td>
                </tr>
		};
    }
    print "<tr><td nowrap>";
    print qq{[<a href="teams/roster_mod.cgi?ACTION=add&teamID=$teamID">add player</a>] <br>};
    print "</td></tr>";
    print "</table>";
}

# keepin perl happy...
return 1;







