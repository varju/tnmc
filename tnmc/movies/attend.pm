package tnmc::movies::attend;

use strict;

use tnmc::db;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(set_attendance get_attendance list_my_attendance);
@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub set_attendance{
    my (%attendance, $junk) = @_;
    my ($sql, $sth, $return);
    
    &db_set_row(\%attendance, $dbh_tnmc, 'MovieAttendance', 'userID');
}

sub get_attendance{
    my ($userID, $attendance_ref, $junk) = @_;
    my ($condition);

    $condition = "userID = '$userID'";
    &db_get_row($attendance_ref, $dbh_tnmc, 'MovieAttendance', $condition);
}

sub list_my_attendance{

    my ($userID) = @_;
    
    # Get User's attendance
    my %attendance;
    &get_attendance($userID, \%attendance);

    # Get the list of dates
    my @movieDates;
    foreach (keys %attendance){
    if (!/^movie(\d+)/) {next;}
    push (@movieDates, $1);
    }
    @movieDates = sort(@movieDates);

    # print some opening crap
    print qq{
    };

    print qq{
    <table border=0 cellpadding=1 cellspacing=0 width="100%">
        <tr bgcolor="cccccc">
        <td norwrap>
        <form action="/movies/attendance_submit.cgi" method="post">
        <input type="hidden" name="userID" value="$userID">&nbsp;&nbsp;
        </td>
        <td align="center"><b>Default</td>
        <td>&nbsp;&nbsp;</td>
    };

    my $tuesdayDate;
    foreach $tuesdayDate (@movieDates){
    my $sql = "SELECT DATE_FORMAT('$tuesdayDate', '%b %D')";
    my $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();
        my @row = $sth->fetchrow_array();
    
    print qq{
        <td align="center"><font color="888888"><b>$row[0]&nbsp;</td>
        <td>&nbsp;&nbsp;</td>
    };
    }
    print qq{
        <td>&nbsp;&nbsp;</td>
        <td>&nbsp;&nbsp;</td>
    </tr>
    <tr>
        <td></td>
            <td valign="top"><font size="-1">
            <select name="movieDefault">
            <option value="$attendance{movieDefault}">$attendance{movieDefault}
            <option value="$attendance{movieDefault}">----
            <option>yes
            <option>no
            </select></font>
            </td>
        <td></td>
    };

    foreach $tuesdayDate (@movieDates){
    print qq{
        <td valign="top"><font size="-1">
        <select name="movie$tuesdayDate">
        <option value="$attendance{"movie$tuesdayDate"}">$attendance{"movie$tuesdayDate"}
        <option value="$attendance{"movie$tuesdayDate"}">----
        <option value="">Default
        <option>yes
        <option>no
         </select>
         </td>
        <td></td>
        };

    }
    print qq{
    <td valign="top"><font size="-1"><input type="submit" value="Set Attendance"></form></td>
    </tr>
    </table>
    };
}

1;
