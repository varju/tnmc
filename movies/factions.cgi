#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc/';

use tnmc::template;
use tnmc::security::auth;
use tnmc::movies::faction;
use tnmc::user;
use tnmc::movies::night;

#############
### Main logic

&header();

&show_heading("Factions");
my @factions = &tnmc::movies::faction::list_factions();

print "<a href='/movies/faction_edit_admin.cgi?factionID=0'>New Faction</a><p>" if ($USERID{groupMovies} >= 100);
foreach my $factionID (@factions){
    &show_faction($factionID);
}

&footer();


#
# subs
#

sub show_faction{
    my ($factionID) = @_;
    
    my $faction = &tnmc::movies::faction::get_faction($factionID);
    my %god;
    my @users = &tnmc::movies::faction::list_faction_members($factionID);
    my $is_faction_admin = ($faction->{godID} == $USERID || $USERID{groupMovies} >= 100)? 1 : 0;
    
    &tnmc::user::get_user($faction->{'godID'}, \%god);
    &show_heading("$faction->{'name'}");
    
    print qq{
        <table border=0 cellpadding=0 cellspacing=0>
            <tr><td colspan=2>
        $faction->{description}<br><br>
            </td></tr>
            <tr valign="top"><td><b>Movie-god:</b></td><td> $god{username}</td></tr>
            <tr valign="top"><td><b>Theatres:</b></td><td> $faction->{'theatres'}</td>
            <tr valign="top"><td><b>Weekly:</b></td><td> $faction->{'night_creation'}</td></tr>
            <tr valign="top"><td><b>Members:</b></td><td>
                };
    
    my @users = sort {my $aa = tnmc::user::get_user_cache($a);
                      my $bb = tnmc::user::get_user_cache($b);
                      $aa->{username} cmp $bb->{username};} @users;
    
    foreach my $userID (@users){
        my $user = &tnmc::user::get_user_cache($userID);
        my $prefs = &tnmc::movies::faction::load_faction_prefs($factionID, $userID);
        my $fontdef = ($prefs->{attendance} <= -1)? 'color="cccccc"' : 'color="000000"';
        print "<font $fontdef>$user->{username}</font>";
        print " ";
    }
    if ($is_faction_admin){
        print qq{
            <br>
            <form action="/movies/faction_prefs_edit.cgi" method="get">
            <input type="hidden" name="factionID" value="$factionID">
            <select name="userID">
        };
        my $newuserlist = &tnmc::user::get_user_list("WHERE groupMovies >= 1");
        foreach my $username (sort keys %$newuserlist){
            print "<option value='$newuserlist->{$username}'>$username\n";
        }
        print qq{
            </select>
            <input type="submit" value="Add/Edit">
            </form>
        };
            
    }
    print qq{
        </td></tr>
            <tr valign="top"><td><b>Upcoming Nights:</b></td><td> 
    };
    my @nights = &tnmc::movies::night::list_future_nights($factionID);
    foreach my $nightID (@nights){
        my %night; &tnmc::movies::night::get_night($nightID, \%night);
        print qq{<a href="/movies/index.cgi?nightID=$nightID">$night{'date'}</a><br>};
    }
    print qq{
                </td></tr>
            <tr>
            <td colspan=2><br>
    };
    print qq{<a href="/movies/faction_edit_admin.cgi?factionID=$factionID">admin</a> - delete - } if $is_faction_admin;
    print qq{<a href="/movies/night_create.cgi?factionID=$factionID">new night</a> -  } if $is_faction_admin;
    
    print qq{
        <a href="/movies/faction_prefs_edit.cgi?factionID=$factionID&userID=$USERID">prefs</a>
        <br>
        <br>
            </td></tr>
        </table>
    };
}
