#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;

require 'pics/PICS.pl';

{
	#############
	### Main logic
	
	$cgih = new CGI;

        my $picID = $cgih->param(picID);
        my $albumID = $cgih->param(albumID);
	my $confirm = $cgih->param(confirm);
        my $destination = $cgih->param(destination) || $ENV{HTTP_REFERER};


	&db_connect();
        &header();
        &show_heading("unlink pic");

        my $link = &get_link($picID, $albumID);

        my (%pic, %album);
        &get_pic($picID, \%pic);
        &get_album($albumID, \%album);
        
        my $pic_img = &get_pic_url($picID, ['mode'=>'thumb']);
        
        ## not linked!
        if (!$link){

            
            print qq{
                <p>
                <b><font color="ff0000">Error:</font> Not a link</b><br>
                Pic "<b>$pic{title}</b>" ($picID) from album "<b>$album{albumTitle}</b>"($albumID) are not linked.. (therefore they cannot be unlinked)
                <p>
                <a href="$destination">Continue</a>
                <p>

                <img src="$pic_img">
            };
        }
        ## not your album
        if ($album{albumOwnerID} ne $USERID){
            print qq{
                <p>
                <b><font color="ff0000">Error:</font> Not your album</b><br>
                You don't own the album "<b>$album{albumTitle}</b>"($albumID) and aren't allowed to modify its contents.
                <p>
                <a href="$destination">Continue</a>
                <p>

                <img src="$pic_img">
            };
        }
        ## get confirmation first
        elsif ($confirm ne 'yes'){
            my $destination = $cgih->param(destination) || $ENV{HTTP_REFERER};

            print qq{
                <p>
                Unlink pic "<b>$pic{title}</b>" ($picID) from album "<b>$album{albumTitle}</b>"($albumID)?

                <form action="link_del.cgi" method="post">
                <input type="hidden" name="picID" value="$picID">
                <input type="hidden" name="albumID" value="$albumID">
                <input type="hidden" name="confirm" value="yes">
                <input type="hidden" name="destination" value="$destination">
                <input type="submit" value="Remove">
                </form>

                <img src="$pic_img">
            };
        }
        ## have confirmation, delete link
        else{
            &del_link($picID, $albumID);

            $destination = $cgih->param(destination);
            
            print qq{
                <p>
                Pic "<b>$pic{title}</b>" ($picID) has been unlinked from album "<b>$album{albumTitle}</b>"($albumID).

                <p>
                <a href="$destination">Continue</a>
            };
        }

	&footer();
	&db_disconnect();

}

