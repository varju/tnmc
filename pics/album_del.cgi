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

use tnmc::pics::album;
use tnmc::pics::link

{
	#############
	### Main logic

	&header();

	%album;	
	$cgih = &tnmc::cgi::get_cgih();
	$albumID = $cgih->param('albumID');
	$CONFIRM = $cgih->param('CONFIRM');
	
       	&get_album($albumID, \%album);

        if (!$albumID){
            ### Bad albumID
            print qq{
                <b>Hey!</b><br>
                No album ID!!
            };
        }
        if ($album{albumOwnerID} != $USERID){
            ### Bad userID
            print qq{
                <b>Hey!</b><br>
                You\'re not allowed to do this!!
            };
        }
        else{

            if (!$CONFIRM){
                ### Ask for confirmation
                print qq {
                    <form action="album_del.cgi" method="post">
                    <input type="hidden" name="albumID" value="$albumID">
                    <b>Are you SURE that you want to permanently delete this album?</b>
                    <p>
                    $album{albumTitle} ($albumID)
                    <p>
                    <input type="checkbox" name="CONFIRM" value="1">Yes
                    <p>
                    <input type="submit" value="Delete this Album">
                    </form>

                };
            }else{
                ### Delete the album

                print qq{
                    <b>Album Deleted:</b>
                    <p>
                    $album{albumTitle} ($albumID)
                };
                
                $sql = "DELETE FROM PicLinks WHERE albumID = $albumID";
                $sth = $dbh_tnmc->prepare($sql);
                $sth->execute();

                &del_album($albumID);

                print qq{
                    <p>
                    <a href="album_list.cgi">Continue</a>
                };
            }
        }
	
	&footer();

}
