#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::cgi;
use tnmc::user;
use tnmc::pics::pic;
use tnmc::pics::link;
use tnmc::pics::album;
use tnmc::pics::show;
use tnmc::pics::new;


#############
### Main logic

&db_connect();
&header();

my $nav = &get_nav();

&show_album_view($nav);

&footer();
&db_disconnect();

#
# subs
#

sub show_album_view{
    my ($nav) = @_;
    
    ## get some info
    my %album;
    &get_album($nav->{'albumID'}, \%album);
    &get_user($album{albumOwnerID}, \%owner);
    
    ## heading
    &show_heading(qq|
        <a href="/pics/"><font color="ffffff">Pics</font></a> -> 
        <a href="album_index.cgi"><font color="ffffff">Albums</font></a> -> 
        $album{'albumTitle'}
        |);
    
    ## some info about the album
    my $albumID = $nav->{albumID};
    my $displayLevel = $nav->{listType};
    
    if (! $album{albumTitle}){
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
        [ <a href="album_thumb.cgi?albumID=$albumID">Thumbnails</a> 
        - <a href="album_slide.cgi?albumID=$albumID">Slideshow</a> ]
        <p>
    };
    
    ## Admin options 
    if ($album{albumOwnerID} == $USERID || $USERID == 1){
        print  qq{
            [ <a href="album_edit.cgi?albumID=$albumID">Edit</a>
            - <a href="album_edit_admin.cgi?albumID=$albumID">Admin</a>
            - <a href="album_del.cgi?albumID=$albumID">Del</a> ]
            <p>
        };
    }
    

    if ($album{albumOwnerID} == $USERID){
        
        print qq{
            <hr noshade size="2"><p>
            <b>Album Admin Options</a><br>
        };
        
        if ( (!$album{albumTypePublic}) && ($USERID == $album{albumOwnerID})){
            print qq{<p>
                <form method="post" action="pic_edit_list_submit.cgi">
                <input type="hidden" name="destination" value="$ENV{REQUEST_URI}">
            };
                
            my @pics;
            &list_links_for_album(\@pics, $albumID);
            foreach my $picID (@pics){
                print qq{<input type="hidden" name="PIC${picID}_typePublic" value="1">\n};
            }
            
            print qq{
                <input type="submit" value="Release All Pics">
                </form>
            };
        }
            
        print qq{
            <p>
            <form action="link_add.cgi" method="post">
            <b>Add PicID:</b>
            <input type="hidden" name="albumID" value="$albumID">
            <input type="text" name="picID">
            <input type="submit" value="Add">
            </form>
        };

    }

}

