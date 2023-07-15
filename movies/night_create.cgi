#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::general_config;
use tnmc::template;
use tnmc::movies::movie;
use tnmc::movies::night;
use tnmc::movies::show;
use tnmc::movies::faction;
use tnmc::cgi;
use tnmc::user;

#############
### Main logic

&tnmc::template::header();

my $factionID = &tnmc::cgi::param('factionID');

&show_night_create_form($factionID);

&tnmc::template::footer();

#
# subs
#

sub show_night_create_form {
    my ($FACTIONID) = @_;

    my $FACTION = &tnmc::movies::faction::get_faction($factionID);

    my $nightID = 0;
    my %night   = (
        'nightID'        => $nightID,
        'factionID'      => $FACTIONID,
        'godID'          => $FACTION->{godID},
        'valid_theatres' => $FACTION->{'theatres'}
    );

    my (@movies, %movie);

    # movieID select list
    &tnmc::movies::show::list_movies(\@movies, "WHERE statusShowing AND NOT (statusSeen OR 0)", 'ORDER BY title');
    my %movieID_sel = ($night{'movieID'}, 'SELECTED');

    # factionID select list
    my @factions      = &tnmc::movies::faction::list_factions();
    my %factionID_sel = ($night{'factionID'}, 'SELECTED');

    # godID select list
    my $users     = &tnmc::user::get_user_list();
    my %godID_sel = ($night{'godID'}, 'SELECTED');

    # show the form to the user...
    &tnmc::template::show_heading("Create Movie Night");

    print qq{
        <form action="movies/night_edit_admin_submit.cgi" method="post">
        <input type="hidden" name="nightID" value="0">
        <input type="hidden" name="LOCATION" value="$ENV{HTTP_REFERER}">
        <table>

            <tr>
            <td><b>date</td>
            <td><select name="date">
            };
    my $dbh = &tnmc::db::db_connect();
    my $sql = "SELECT DATE_ADD(CURDATE(), INTERVAL ? DAY), DATE_FORMAT(DATE_ADD(NOW(), INTERVAL ? DAY), '%a, %b %D')";
    my $sth = $dbh->prepare($sql);
    for (my $i = 0 ; $i <= 45 ; $i++) {
        $sth->execute($i, $i);
        my ($val, $text) = $sth->fetchrow_array();
        print "<option value='$val 23:00:00'>$text\n";
    }
    print qq{
                </select>
            </td>
            </tr>

            <tr>
            <td><b>Movie God</td>
            <td><select name="godID">
                <option value="0">NO CURRENT MOVIE

    };

    foreach my $username (sort keys %$users) {
        my $userID = $users->{$username};
        print qq{
                <option value="$userID" $godID_sel{$userID} >$username
        };
    }

    print qq{
                </select>
            </td>
            </tr>

            <tr>
            <td><b>Movie</td>
            <td><select name="movieID">
                <option value="0">NO CURRENT MOVIE
    };

    foreach my $movieID (@movies) {
        &tnmc::movies::movie::get_movie($movieID, \%movie);
        print qq{
                <option value="$movie{'movieID'}" $movieID_sel{$movieID} >$movie{'title'}
        };
    }

    print qq{
                </select>
            </tr>

            <tr>
            <td><b>Faction</td>
            <td><select name="factionID">
    };
    foreach my $factionID (@factions) {
        my $faction = &tnmc::movies::faction::get_faction($factionID);
        print qq{
            <option value="$factionID" $factionID_sel{$factionID} >$faction->{name}
        };
    }

    print qq{
                </select>
            </tr>

            <tr>
            <td><b>Cinema</td>
            <td><input type="text" name="theatre" value="$night{'theatre'}")></td>
            </tr>

            <tr>
            <td><b>Showtime</td>
            <td><input type="text" name="showtime" value="$night{'showtime'}"></td>
            </tr>

            <tr>
            <td><b>Meeting Place</td>
            <td><input type="text" name="meetingPlace" value="$night{'meetingPlace'}"></td>
            </tr>

            <tr>
            <td><b>Meeting Time</td>
            <td><input type="text" name="meetingTime" value="$night{'meetingTime'}"></td>
            </tr>

            <tr>
            <td><b>Vote Blurb</b><br>(sunday email)</td>
            <td><textarea cols="19" rows="5" wrap="virtual" name="voteBlurb">$night{'voteBlurb'}</textarea></td>
            </tr>

            <tr>
            <td><b>Winner Blurb</b><br>(tuesday email)</td>
            <td><textarea cols="19" rows="5" wrap="virtual" name="winnerBlurb">$night{'winnerBlurb'}</textarea></td>
            </tr>

            </table>
            <p>
            <input type="image" border=0 src="/template/submit.gif" alt="Submit Changes">
            </form>
    };

}

