#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib::db;
use lib::blat;
use lib::template;
use lib::cgi;
use lib::date;

#############
### Main logic

&header();

my $playerid = $cgih->param('playerid');
my $player = &lib::blat::get_player($playerid);

my @games = &lib::blat::list_games();
my %attendance_names = &lib::blat::attendance_names();


print qq {
    Attendance for $player->{name}
    <form action="attendance_submit.cgi" method="post">
    <table>
};

foreach my $gameid (@games){
    my $attendance = &lib::blat::get_attendance($playerid, $gameid);
    my $game = &lib::blat::get_game($gameid);
    my $date = &lib::date::format_date('short_month_day', $game->{"date"});
    
    print qq{
        <tr>
            <td><b>$date</td>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
            <td>$game->{'type'}</td>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
            <td>
                <select name="attendance_${playerid}_${gameid}">
                    <option value="$attendance->{'type'}">$attendance_names{$attendance->{'type'}}</option>
                    <option value="$attendance->{'type'}"></option>
                    <option value="2">$attendance_names{2}</option>
                    <option value="1">$attendance_names{1}</option>
                    <option value="-1">$attendance_names{-1}</option>
                </select>
        </tr>
    };
}

print qq{
    </table>
    <input type="submit" value="Submit">
    </form>
}; 

&footer();
