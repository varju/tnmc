#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::template;

use tnmc::pics::pic;
use tnmc::pics::album;
use tnmc::pics::link;
use tnmc::pics::show;

#############
### Main logic

&header();

&show_all_albums();

&footer();



###################################################################
sub show_all_albums{
    
    &show_heading("Albums");
    
    my @albums;
    &list_albums
        ( \@albums, 
          "WHERE (( albumOwnerID = '$USERID') OR albumTypePublic >= 1)",
          "ORDER BY albumDateStart DESC, albumTitle LIMIT 30"
          );
    
#    &show_album_listing(\@albums,);
    foreach $albumID(@albums){
        &show_album_info($albumID);
    }
    print qq{
        <a href="album_list.cgi">More albums...</a>
        <p>
    };
}

