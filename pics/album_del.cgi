#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::cgi;

use tnmc::pics::album;
use tnmc::pics::link;

{
    #############
    ### Main logic

    &tnmc::template::header();

    %album;
    $albumID = &tnmc::cgi::param('albumID');
    $CONFIRM = &tnmc::cgi::param('CONFIRM');

    &tnmc::pics::album::get_album($albumID, \%album);

    if (!$albumID) {
        ### Bad albumID
        print qq{
                <b>Hey!</b><br>
                No album ID!!
            };
    }
    if ($album{albumOwnerID} != $USERID) {
        ### Bad userID
        print qq{
                <b>Hey!</b><br>
                You\'re not allowed to do this!!
            };
    }
    else {

        if (!$CONFIRM) {
            ### Ask for confirmation
            print qq {
                    <form action="pics/album_del.cgi" method="post">
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
        }
        else {
            ### Delete the album

            my $dbh = &tnmc::db::db_connect();

            print qq{
                    <b>Album Deleted:</b>
                    <p>
                    $album{albumTitle} ($albumID)
                };

            $sql = "DELETE FROM PicLinks WHERE albumID = $albumID";
            $sth = $dbh->prepare($sql);
            $sth->execute();

            &tnmc::pics::album::del_album($albumID);

            print qq{
                    <p>
                    <a href="pics/index.cgi">Continue</a>
                };
        }
    }

    &tnmc::template::footer();
}
