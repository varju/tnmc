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

$cgih = &tnmc::cgi::get_cgih();

## get the cgi info
@cols = &db_get_cols_list('PicAlbums');
foreach $key (@cols){
    $album{$key} = $cgih->param($key);
}

## save the album
&set_album(%album);

## try to get the albumID
$sql = "SELECT albumID from PicAlbums WHERE albumTitle = ? AND albumOwnerID = ? AND albumDateStart = ? AND albumDateEnd = ?";
$sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
$sth->execute($album{albumTitle}, $album{albumOwnerID}, $album{albumDateStart}, $album{albumDateEnd});
($albumID, $junk)  = $sth->fetchrow_array();
$sth->finish;

## if we got the albumID, grab the pics..
if ($albumID){
    my @PICS;
    &list_pics(\@PICS,
               "WHERE timestamp >= '$album{albumDateStart}' 
                  AND timestamp <= '$album{albumDateEnd}'"
               , "");
    foreach $picID (@PICS){
        &add_link($picID, $albumID);
    }
    
    print "Location: album_view.cgi?albumID=$albumID\n\n";
}

## otherwise, print an error
else{
    &header();
    print "<b>Error: Could not determine albumID!!!</b><br>\n";
    print "Album May have been partially created, but pics could not be added. Please investigate this before trying again<br>\n";
    print "<hr> <b>Dump:</b> <b>";
    print %album;
    &footer();
}




