#!/usr/bin/perl
##################################################################
#	Scott Thompson - scottt@css.sfu.ca (nov/98)
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.



use CGI;

use lib::db;
use lib::template;
use lib::cgi;
use lib::blat;
use lib::date;
#use lib::auth;
use lib::pics;

#
# Main
#


&header();

print qq{<table  cellpadding=0 cellspacing=0 border=0><tr valign=top><td>};
&show_roster_tally();
print qq{</td><td width=20></td></tr><tr><td>};
&show_player_list();
print qq{</td><td width=20></td></tr><tr><td>};
&show_pics_link();
print qq{</td></tr></table>};
#&show_game_list();
&footer;

sub show_pics_link{
    &table_open();
    &table_title("Pictures");
    
    my @albums = &lib::pics::list_albums();
    
    foreach my $albumID (@albums){
        print "<tr><td><a href=\"pics/pic_list.cgi?albumID=$albumID\">$albumID</a></td></tr>\n";
    }

    print qq{
        <tr><td>
            <a href=\"pics/make_thumbnails.cgi\">[Make Thumbnails]</a> -
            <a href=\"pics/upload.cgi\">[Upload Pics]</a>
        </td></tr>
    };
    &table_close();
}



sub show_player_list{
    my @players = &lib::blat::list_players();
    my @gameids = &lib::blat::get_upcoming_gameids();
    my %attendance_names = &lib::blat::attendance_names();
    
    &table_open();
    &table_title("Players");
    print "<tr><th>Name</th><th>M/F</th><th>Phone</th>";
    foreach $gameid (@gameids){
        my $game = &lib::blat::get_game($gameid);
        my $game_date = &lib::date::format_date('short_month_day', $game->{"date"});
        print "<th nowrap>$game_date</th>";
    }
    print "<th></th></tr>\n";
    foreach my $playerid (@players){
        my $player = &lib::blat::get_player($playerid);
        print qq{
            <tr>
            <td><a href="player_edit.cgi?playerid=$playerid">$player->{"name"}</a></td>
            <td>$player->{"gender"}</td>
            <td>$player->{"phone"}</td>
        };
        
        foreach $gameid (@gameids){
            my $attendance = &lib::blat::player_is_coming_to_game($playerid, $gameid);
            print "<td>$attendance_names{$attendance}</td>\n";
        }
        print qq{
            <td>[<a href="player_attendance_edit.cgi?playerid=$playerid">games</a>]</td>
                </tr>
            };
    }
    print "<tr><td>";
    print qq{[<a href="player_edit.cgi?playerid=0">new</a>] <br>};
    print "</td></tr>";
    &table_close();
}


sub show_game_list{
    my @games = &lib::blat::list_games();
    &table_open();
    &table_title("Games");
    print "<tr><td>";
    foreach my $gameid (@games){
        my $game = &lib::blat::get_game($gameid);
        my $date = &lib::date::format_date('short_month_day', $game->{"date"});
        print qq{<a href="game_edit_admin.cgi?gameid=$gameid">$date</a> };
    }
    print qq{[<a href="game_edit_admin.cgi?gameid=0">new</a>] <br>};
    print "</td></tr>";
    &table_close();
}

sub show_roster_tally{
    my @games = &lib::blat::list_games();
    my @players = &lib::blat::list_players();
    
    &table_open();
    &table_title("Games");
    print "<tr><th>Date</th><th>M</th><th>F</th><th>Y/?/N</th><th>Players</th></tr>\n";
    foreach my $gameid (@games){
        my $game = &lib::blat::get_game($gameid);
        my $date = &lib::date::format_date('day_time', $game->{"date"});
        my %totals = ('M', 0, 'F', 0, 'yes', 0, 'maybe', 0, 'no', 0);
        my $players_text = '';
        foreach my $playerid (@players){
            my $attendance = &lib::blat::player_is_coming_to_game($playerid, $gameid);
            if ($attendance == 2){
                my $player = &lib::blat::get_player($playerid);
                $totals{$player->{"gender"}} ++;
                $totals{"yes"} ++;
                $players_text .= "$player->{name} ";
            }
            elsif ($attendance == 1){
                $totals{"maybe"} ++;
            }
            elsif ($attendance == -1){
                $totals{"no"} ++;
            }
            
        }
        
        print "<tr><td nowrap><a href=\"game_edit_admin.cgi?gameid=$gameid\"><b>$date</b></a> ($game->{type} @ $game->{location} )</td>\n";
        print (($totals{'M'} < 5 )? "<td><b>$totals{'M'}</b></td>" :"<td>$totals{'M'}</td>") ;
        print (($totals{'F'} < 4 )? "<td><b>$totals{'F'}</b></td>" :"<td>$totals{'F'}</td>" );
        print "<td>$totals{'yes'}-$totals{'maybe'}-$totals{'no'}</td>" ;
        print "<td>$players_text</td>";
        print "</tr>\n";
        
    }
    print "<tr><td>";
    print qq{[<a href="game_edit_admin.cgi?gameid=0">new</a>] <br>};
    print "</td></tr>";
    &table_close();
}

1;







