#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
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

&header();

my $cgih = &tnmc::cgi::get_cgih();

my $nightID = $cgih->param('nightID');

&show_night_edit_form($nightID);

&footer();

#
# subs
#

sub show_night_edit_form{
    my ($nightID) = @_;
    
    my %night;
    &get_night($nightID, \%night);
    
    # movieID select list
    my @movies = &tnmc::movies::night::list_cache_movieIDs($nightID);
    my %movieID_sel = ($night{'movieID'}, 'SELECTED');
    
    # factionID select list
    my @factions = &tnmc::movies::faction::list_factions();
    my %factionID_sel = ($night{'factionID'}, 'SELECTED');
    
    # godID select list
    my $users = &get_user_list();
    my %godID_sel = ($night{'godID'}, 'SELECTED');
    
    # show the form to the user...
    &show_heading("Edit/Set Movie Night");
    
    print qq{
        <form action="night_edit_submit.cgi" method="post">
        <input type="hidden" name="nightID" value="$nightID">
        <input type="hidden" name="LOCATION" value="$ENV{HTTP_REFERER}">
        <table>
        
            <tr>
            <td><b>Movie</td>
            <td><select name="movieID">
                <option value="0">NO CURRENT MOVIE
    };
    
    foreach my $movieID (@movies){
        my %movie;
        &get_movie($movieID, \%movie);
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
    foreach my $factionID (@factions){
        my $faction = &tnmc::movies::faction::get_faction($factionID);
        print qq{
            <option value="$factionID" $factionID_sel{$factionID} >$faction->{name}
        };
    }
    
    print qq{
                </select>
            </tr>

            <tr>
            <td><b>date</td>
            <td><input type="text" name="date" value="$night{'date'}")></td>
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
            <tr>
            <td><b>Movie God</td>
            <td><select name="godID">
                <option value="0">NO CURRENT MOVIE
            
    };
    
    foreach my $username (sort keys %$users){
        my $userID = $users->{$username};
        print qq{
                <option value="$userID" $godID_sel{$userID} >$username
        };
    }
    
    print qq{
                </select>
            </td>
            </tr>

            </table>
            <p>    
            <input type="image" border=0 src="/template/submit.gif" alt="Submit Changes">
            </form>
    }; 

}



