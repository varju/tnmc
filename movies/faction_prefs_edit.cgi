#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc/';

use tnmc::template;
use tnmc::movies::faction;
use tnmc::user;
use tnmc::cgi;

{
    #############
    ### Main logic
    
    &tnmc::template::header();
    
    my $factionID = &tnmc::cgi::param('factionID');
    my $userID = &tnmc::cgi::param('userID');
    
    my $faction = &tnmc::movies::faction::get_faction($factionID);
    my $user = &tnmc::user::get_user_cache($userID);
    my $prefs =  &tnmc::movies::faction::load_faction_prefs($factionID, $userID);
    
    &tnmc::template::show_heading("Faction Prefs for $user->{username} in $faction->{name}");
    
    my %sel_membership = ($prefs->{membership} => 'checked');
    my %sel_attendance = ($prefs->{attendance} => 'selected');
    my %sel_notify_phone = ($prefs->{notify_phone} => 'checked');
    
    print qq{
            <form action="faction_prefs_edit_admin_submit.cgi" method="post">
            <input type="hidden" name="factionID" value="$prefs->{factionID}">
            <input type="hidden" name="userID" value="$prefs->{userID}">
	    <table>
            
            <tr valign=top><td>Member</td>
            <td>
                <input type="radio" name="membership" value="1"  $sel_membership{'1'}>Yes
                <input type="radio" name="membership" value="-1" $sel_membership{'-1'} $sel_membership{'0'} $sel_membership{''}>No
                </td>
            </tr>
            
            <tr valign=top><td>Default Attendance</td>
            <td>
                <select name="attendance">
                <option value="1" $sel_attendance{'0'}>
                <option value="1" $sel_attendance{'1'}>Yes
                <option value="-1" $sel_attendance{'-1'}>No
                <option value="-2" $sel_attendance{'-2'}>Hide
                </select>
            </tr>
            
            <tr valign=top><td>Cell-phone Notification</td>
            <td>
                <input type="radio" name="notify_phone" value="1"  $sel_notify_phone{'1'}>Yes
                <input type="radio" name="notify_phone" value="0" $sel_notify_phone{'0'} $sel_notify_phone{''}>No
                </td>
            </tr>
            
            </table>
	    <input type="submit" value="Submit">
	    </form>
    };
    
    
    &tnmc::template::footer();
}



