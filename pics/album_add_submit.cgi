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

use tnmc::pics::pic;
use tnmc::pics::album;
use tnmc::pics::link;
use tnmc::pics::show;

#############
### Main logic

&do_add_album();

#
# subs
#

sub do_add_album{
    my %album;
    
    ## get the cgi info
    @cols = &tnmc::db::db_get_cols_list('PicAlbums');
    foreach $key (@cols){
        $album{$key} = &tnmc::cgi::param($key);
    }
    
    ## save the album
    &tnmc::pics::album::set_album(%album);
    
    my $dbh = &tnmc::db::db_connect();

    ## get the albumID
    $sql = "SELECT albumID from PicAlbums WHERE albumTitle = ? AND albumOwnerID = ? AND albumDateStart = ? AND albumDateEnd = ? ORDER BY albumID DESC";
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($album{albumTitle}, $album{albumOwnerID}, $album{albumDateStart}, $album{albumDateEnd});
    ($albumID, $junk)  = $sth->fetchrow_array();
    $sth->finish;
    
    ## complain bitterly if we couldn't find the albumID
    if (!$albumID){
        &tnmc::template::header();
        print "<b>Error: Could not determine albumID!!!</b><br>\n";
        print "Album May have been partially created, but pics could not be added. Please investigate this before trying again<br>\n";
        print "<hr> <b>Dump:</b> <b>";
        print %album;
        &tnmc::template::footer();
        return 0;
    }
    
    ## if the user wants the album pre-filled
    if (&tnmc::cgi::param('optionFill')){
        my @PICS;
        &tnmc::pics::pic::list_pics(\@PICS,
                   "WHERE timestamp >= '$album{albumDateStart}' 
                      AND timestamp <= '$album{albumDateEnd}'
                      AND ((ownerID = '$USERID') OR typePublic >= 1)"
                   , "");
        foreach $picID (@PICS){
            &tnmc::pics::link::add_link($picID, $albumID);
        }
    }
    
    ## send the user to album-view
    print "Location: album_view.cgi?albumID=$albumID\n\n";
}
