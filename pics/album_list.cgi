#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/';
use tnmc;
require 'pics/PICS.pl';

{	
    #############
    ### Main logic
    	
    &db_connect();	
    
    &header();
    
    my $cgih = new CGI;
    
    my $add_link = qq{<a href="album_add.cgi"><font color="ffffff">Add</font></a>};

    &show_heading("Albums - $add_link");
        
    &show_all_albums();
    
    &footer();
    &db_disconnect();
}


###################################################################
sub show_all_albums{

    my @albums;
    &list_albums(\@albums, 
                 "WHERE (( albumOwnerID = '$USERID') OR albumTypePublic = 1)",
                 "ORDER BY albumDateStart DESC, albumTitle");

    &show_album_listing(\@albums);


    
}


