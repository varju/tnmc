#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;

use tnmc::pics::pic;
use tnmc::pics::link;
use tnmc::pics::album;
use tnmc::pics::show;

#############
### Main logic

&db_connect();	
&header();

my $cgih = new CGI;

&show_all_albums();

&footer();
&db_disconnect();


###################################################################
sub show_all_albums{
    
    my $add_link = qq{<a href="album_add.cgi"><font color="ffffff">Add</font></a>};
    
    &show_heading("Albums - $add_link");
    
    my @albums;
    &list_albums(\@albums, 
                 "WHERE (( albumOwnerID = '$USERID') OR albumTypePublic = 1)",
                 "ORDER BY albumDateStart DESC, albumTitle");
    
    &show_album_listing(\@albums);
    
}


