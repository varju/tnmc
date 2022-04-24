#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::template;
use tnmc::cgi;
use tnmc::user;

use tnmc::pics::album;
use tnmc::pics::link;
use tnmc::pics::pic;
use tnmc::pics::new;

use strict;

#############
### Main logic

&tnmc::template::header();

my $albumID = &tnmc::cgi::param('albumID');

if (&tnmc::pics::new::auth_access_album_edit($albumID, undef)) {
    &show_album_edit_form($albumID);
}
else {
    print qq{
        You don\'t have permission to edit this album.
    };
}
&tnmc::template::footer();

#
# subs
#

sub show_album_edit_form {
    my ($albumID) = @_;
    my %album;
    &tnmc::pics::album::get_album($albumID, \%album);

    &tnmc::template::show_heading("album edit");
    print qq {
        <form action="pics/album_edit_submit.cgi" method="post">
        <input type="hidden" name="albumID" value="$albumID">
            <p>
            <b>Title</b><br>
            <input type="text" name="albumTitle" value="$album{albumTitle}" size="40"><br>
            <br>
            <b>Description</b><br>
            <textarea name="albumDescription" wrap="virtual" cols="38" rows="4">$album{albumDescription}</textarea><br>
            <table> 
    };

    ## date
    foreach my $key ('albumDateStart', 'albumDateEnd') {
        print qq{
            <tr><td><b>$key</td>
                <td><input type="text" name="$key" value="$album{$key}"></td>
                </tr>
	};
    }

    ## Public/Private
    my %sel = ($album{albumTypePublic} => 'selected');
    print qq{
        <tr><td><b>Access</b></td>
            <td><select name="albumTypePublic">
                <option $sel{2} value="2">Public view/edit
                <option $sel{1} value="1">Public view
                <option $sel{0} value="0">Hidden
                </select>
            </td></tr>
    };

    ## Cover Pic
    %sel = ($album{albumCoverPic} => 'selected');
    print qq{
        <tr><td><b>Cover Pic</b></td>
            <td><select name="albumCoverPic">
    };
    my @pics;
    &tnmc::pics::link::list_links_for_album(\@pics, $albumID);
    foreach my $picID (@pics) {
        my %pic;
        &tnmc::pics::pic::get_pic($picID, \%pic, $picID);
        print qq{<option $sel{$picID} value="$picID">$picID - $pic{title}</option>\n};
    }
    print qq{
                </select>
            </td></tr>
    };

    ## Owner
    %sel = ($album{albumOwnerID} => 'selected');
    print qq{
        <tr><td><b>Owner</b></td>
            <td><select name="albumOwnerID">
    };
    my $users = &tnmc::user::get_user_list("WHERE groupPics >= 1");
    foreach my $username (sort keys %$users) {
        my $userID = $users->{$username};
        print qq{<option $sel{$userID} value="$userID">$username</option>\n};
    }
    print qq{
                </select>
            </td></tr>
    };

    ## submit

    print qq{
        </table>
        <input type="submit" value="Submit">
        </form>
    };

}
