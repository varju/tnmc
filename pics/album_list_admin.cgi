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

	&db_connect();
	&header();

        my @ALBUMS;

        &list_albums(\@ALBUMS, "", "ORDER BY albumID");

        &show_heading('edit albums');
        print qq{
            <ol>
        };

        foreach $albumID (@ALBUMS){
       
            &get_album($albumID, \%album);
	  	
            if (!$album{albumTitle}){
                $album{albumTitle} = '(untitled)';
            }

            print qq {
                <li value="$albumID">
                <a href="album_edit_admin.cgi?albumID=$albumID">$album{albumTitle}</a>
            };
        }
	
	print qq{
            </ol>
	}; 

	
	&footer();

	&db_disconnect();
}

