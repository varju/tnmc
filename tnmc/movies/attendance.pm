package tnmc::movies::attendance;

use strict;
use warnings;

use tnmc::db;

#
# module configuration
#

#
# module routines
#

sub set_attendance {
    my ($ref, $junk) = @_;

    # make sure we have a handle
    my $dbh = &tnmc::db::db_connect();

    if ($ref->{'type'} != 0) {
        my @keys = sort keys %$ref;

        my $key_list = join(',', @keys);
        my $ref_list = join(',', (map { sprintf '?' } @keys));
        my @var_list = map { $ref->{$_} } @keys;

        # save to the db
        my $sql = "REPLACE INTO MovieNightAttendance ($key_list) VALUES($ref_list)";
        my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
        $sth->execute(@var_list) or return 0;
        $sth->finish;
    }
    else {
        # delete from the db
        my $sql = "DELETE FROM MovieNightAttendance WHERE nightID = ? AND userID = ?";
        my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
        $sth->execute($ref->{'nightID'}, $ref->{'userID'}) or return 0;
        $sth->finish;
    }
}

sub get_attendance {
    my ($userID, $nightID, $row_ref) = @_;

    # make sure we have a handle
    my $dbh = &tnmc::db::db_connect();

    # fetch from the db
    my $sql = "SELECT * from MovieNightAttendance WHERE userID = ? AND nightID = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($userID, $nightID) or return ();
    my $row = $sth->fetchrow_hashref();
    $sth->finish;
    if ($row) {
        %{$row_ref} = %{$row};
    }
}

sub get_night_attendance_hash {
    my ($nightID) = @_;

    require tnmc::movies::night;

    my %hash;

    # make sure we have a handle
    my $dbh = &tnmc::db::db_connect();
    my ($sql, $sth);

    ### look for a parent faction
    my %night;
    &tnmc::movies::night::get_night($nightID, \%night);

    ### first, get the defaults
    if ($night{'factionID'}) {
        $sql = "SELECT userID, attendance from MovieFactionPrefs WHERE factionID = ?";
        $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
        $sth->execute($night{'factionID'});

        while (my @row = $sth->fetchrow_array()) {
            $hash{ $row[0] } = $row[1];
        }
    }

    ### second, get the night attendance
    $sql = "SELECT userID, type from MovieNightAttendance WHERE nightID = ? AND type != 0";
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($nightID);

    while (my @row = $sth->fetchrow_array()) {
        $hash{ $row[0] } = $row[1];
    }
    $sth->finish;

    # return the data
    return \%hash;
}

sub show_my_attendance_chooser {
    my ($userID, $selected_nightID) = @_;

    require tnmc::util::date;
    require tnmc::movies::faction;
    require tnmc::movies::night;
    require tnmc::user;

    my $user = &tnmc::user::get_user_cache($userID);

    # get the list of nights
    my @all_nights = &tnmc::movies::night::list_future_nights();
    my @nights     = ();
    my %nights;
    my %factions;
    my %attendances;
    my %prefss;

    # pre-load night/faction info
    foreach my $nightID (@all_nights) {
        my %night;
        &tnmc::movies::night::get_night($nightID, \%night);
        $nights{$nightID} = \%night;
        my $factionID = $night{'factionID'};
        $factions{$factionID} = &tnmc::movies::faction::get_faction($factionID) if (!defined $factions{$factionID});
        my %attendance;
        &get_attendance($userID, $nightID, \%attendance);
        $attendances{$nightID} = \%attendance;
        $prefss{$factionID}    = &tnmc::movies::faction::load_faction_prefs($factionID, $userID)
          if (!defined $prefss{$factionID});

        if ($prefss{$factionID}->{'membership'} == 1 ||
            ($attendance{'type'} && $attendance{'type'} != -2) ||
            $night{'godID'} == $userID ||
            $nightID == $selected_nightID)
        {
            push(@nights, $nightID);
        }
    }

    # print some opening crap
    print qq{
    <table border=0 cellpadding=1 cellspacing=0 width="100%">
        <tr bgcolor="cccccc">
    };

    ### Date/faction
    foreach my $nightID (@nights) {
        my $night       = $nights{$nightID};
        my $faction     = $factions{ $night->{'factionID'} };
        my $date_string = &tnmc::util::date::format_date('short_month_day', $night->{date});
        $date_string =~ s/\s/\&nbsp\;/;
        if ($nightID == $selected_nightID) {
            print qq{
                <td align="center" bgcolor="888888"><font color="cccccc"><b>$date_string</b></font></td>
                <td>&nbsp;&nbsp;</td>
            };
        }
        else {
            print qq{
                <td align="center"><a href="movies/index.cgi?nightID=$nightID&effectiveUserID=$userID"><font color="888888"><b>$date_string</b></font></a></td>
                <td>&nbsp;&nbsp;</td>
            };
        }
    }

    print qq{
        <td>\&nbsp\;\&nbsp\;</td>
    };

    ### Yes/No/Hide
    if ($userID) {

        print qq{
            <td>
            <!-- hide the form tag here so it doesn\'t strech things -->
            <form action="movies/night_attendance_submit.cgi" method="post"
		name="MovieAttendance" id="MovieAttendance">
            <input type="hidden" name="userID" value="$userID">\&nbsp\;
            </td>
            </tr>
            <tr>
        };

        my %attendance_names = (1, 'yes', -1, 'no', -2, 'hide');

        foreach my $nightID (@nights) {
            my $night      = $nights{$nightID};
            my $attendance = $attendances{$nightID};
            my $prefs      = $prefss{ $night->{'factionID'} };

            my %sel = ($attendance->{'type'} => 'selected');

            print qq{
                <td valign="top" align="center"><font size="-1">
                    <select name="night_$nightID" onChange="form.submit();">
                        <option value="1" $sel{'1'}>yes
                            <option value="-1" $sel{'-1'}>no
                            };
            if ($prefs->{'attendance'}) {
                print qq{
                    <option value="-2" $sel{'-2'}>hide
                    <option value="$attendance->{'type'}">---
                    <option value="0">default:
                    <option value="0" $sel{undef()} $sel{'0'}> ($attendance_names{$prefs->{'attendance'}})
                };
            }
            else {
                print qq{
                    <option value="0" $sel{'-2'} $sel{'0'} $sel{undef()}>hide
                    };

            }
            print qq{
                </select>
                </td>
                <td></td>
            };
        }

        print qq{
            <td></form></td>
        };

    }

    print qq{
            </tr>
            <tr>
    };

    ### MovieGod / more info
    foreach my $nightID (@nights) {
        my $night   = $nights{$nightID};
        my $faction = $factions{ $night->{'factionID'} };
        my $god     = &tnmc::user::get_user_cache($night->{'godID'});

        print qq{
            <td valign="top" align="center">
               $faction->{'name'}&nbsp(};
        if (($userID == $night->{'godID'}) ||
            ($user->{groupMovies} >= 100))
        {
            print qq{<a href="movies/night_edit.cgi?nightID=$nightID">$god->{'username'}</a>};
        }
        else {
            print $god->{'username'};
        }
        print qq{)
            </td>
            <td></td>
        };
    }

    print qq{
    </table>
    };
}

1;
