#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::template;

use tnmc::pics::album;
use tnmc::pics::show;

#############
### Main logic

&header();

&show_all_albums();

&footer();


###################################################################
sub show_all_albums{
    
    my $add_link = qq{<a href="album_add.cgi"><font color="ffffff">Add</font></a>};
    
    &show_heading("Albums - $add_link");
    
    my @albums;
    &tnmc::pics::album::list_albums(\@albums, 
                 "WHERE (( albumOwnerID = '$USERID') OR albumTypePublic = 1)",
                 "ORDER BY albumDateStart DESC, albumTitle");
    
    &tnmc::pics::show::show_album_listing(\@albums);
    
}


