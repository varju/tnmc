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


&show_page();

&footer();



###################################################################
sub show_page{
    
    &show_heading("Pics");
    ## search
    my $url = "/pics/search_thumb.cgi";
    print qq{
        <table><tr><td>
          <form method="get" action="$url">
          <input type="hidden" name="search" value="text">
          <b>Search:</b> <input type="text" name="search_text" value="">
          <input type="radio" checked name="search_text_join" value="OR">any
          <input type="radio" name="search_text_join" value="AND">all
          &nbsp;&nbsp;&nbsp;
          <input type="submit" value="Go">
          </form>
        </td></tr></table>
        <p>
    };
    
    ## quick links
    print qq{
        <a href="/pics/search_thumb.cgi?search=my_unreleased">my hidden pics</a> - 
        <a href="/pics/album_add.cgi">add album</a> -
        <a href="/pics/upload_index.cgi">upload pics</a>
        <br>
    };
    
    ## recent albums
    &show_heading("Recent Albums");
    my @albums = &list_recent_albums();
    &tnmc::pics::show::show_album_listing_info(\@albums);
    print qq{
        <a href="album_index.cgi">More albums...</a>
        <p>
    };
    
}

sub list_recent_albums{
    ## note: the logic here is pretty lame. it grabs the 7
    ## most recent albums by EndDate, and the 7 most recent by albumID,
    ## then it lazilly combines them.
    
    my (@albums1, @albums2);
    
    &list_albums
        ( \@albums1, 
          "WHERE (( albumOwnerID = '$USERID') OR albumTypePublic >= 1)",
          "ORDER BY albumDateEnd DESC, albumTitle LIMIT 7"
          );
    
    &list_albums
        ( \@albums2, 
          "WHERE (( albumOwnerID = '$USERID') OR albumTypePublic >= 1)",
          "ORDER BY albumID DESC LIMIT 7"
          );
    
    foreach my $albumID (@albums2){
        if (! grep {($_ eq $albumID)} @albums1){
            push @albums1, $albumID;
        }
    }
    return @albums1;
    
}


