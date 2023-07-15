#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::template;
use tnmc::user;

use tnmc::pics::pic;
use tnmc::pics::link;
use tnmc::pics::album;
use tnmc::pics::show;
use tnmc::pics::new;

#############
### Main logic

&tnmc::template::header();

my $nav = &tnmc::pics::new::get_nav();

&show_album_view($nav);

&tnmc::template::footer();

#
# subs
#

sub show_album_view {
    my ($nav) = @_;

    ## get some info
    my %album;
    &tnmc::pics::album::get_album($nav->{'albumID'}, \%album);
    &tnmc::user::get_user($album{albumOwnerID}, \%owner);

    ## heading
    &tnmc::template::show_heading(
        qq|
        <a href="pics/"><font color="ffffff">Pics</font></a> ->
        <a href="pics/album_index.cgi"><font color="ffffff">Albums</font></a> ->
        $album{'albumTitle'}
        |
    );

    ## some info about the album
    my $albumID      = $nav->{albumID};
    my $displayLevel = $nav->{listType};

    if (!$album{albumTitle}) {
        $album{albumTitle} = '(Untitled)';
    }

    print qq{
        <p>
        <b>$album{albumTitle}</b><br>
        $album{albumDescription}
        <p>
        <b>Date:</b> $album{albumDateStart} - $album{albumDateEnd}<br>
        <b>Owner:</b> $owner{username}
        <b>Album ID:</b> $album{albumID}
        <p>
        [ <a href="pics/album_thumb.cgi?albumID=$albumID">Thumbnails</a>
        - <a href="pics/album_slide.cgi?albumID=$albumID">Slideshow</a> ]
        <p>
    };

    ## Admin options
    if (&tnmc::pics::new::auth_access_album_edit($albumID, \%album)) {
        print qq{
            [ <a href="pics/album_edit.cgi?albumID=$albumID">Edit</a>
            - <a href="pics/album_edit_admin.cgi?albumID=$albumID">Admin</a>
            - <a href="pics/album_del.cgi?albumID=$albumID">Del</a> ]
            <p>
        };

    }

}

