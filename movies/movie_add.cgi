#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::db;
use tnmc::template;
use tnmc::movies::show;

{
    #############
    ### Main logic

    &db_connect();
    &header();

    &show_add_movie_form();

    &footer();
    &db_disconnect();
}


##########################################################
sub show_add_movie_form
{

    print qq{
                <form action="movie_edit_submit.cgi" method="post">
                <input type="hidden" name="movieID" value="0">
    };
    &show_heading ("add a new movie");
    
        print qq{
                <table border="0">
                <tr valign=top>
                        <td colspan="4"><b>Title</b><br>
                
                        <input type="text" size="41" name="title" value=""></td>
                </tr>
        
                <tr valign=top>
                        <td><b>Type</b><br>
                        <input type="text" size="12" name="type" value=""></td>

                        <td><b>Rating</b><br>
                        <input type="text" size="3" name="rating" value=""></td>

                        <td><b>MyBC ID</b><br>
                        <input type="text" size="6" name="mybcID" value=""></td>

                        <td><b>Status</b><br><b>
                <input type="radio" name="statusNew" value="1" checked>Y
                <input type="radio" name="statusNew" value="0" >N &nbsp; <b>New</b><br>
                <input type="radio" name="statusShowing" value="1" >Y
                <input type="radio" name="statusShowing" value="0" checked>N &nbsp; <b>Showing</b><br>
                                <input type="hidden" name="statusSeen" value="0">
                                <input type="hidden" name="statusBanned" value="0">
                        </td>  

                </tr> 
        
                <tr valign=top>
                        <td colspan="4"><b>Description</b><br>
                        <textarea cols="40" rows="4" wrap="virtual" name="description"></textarea></td>
                </tr>
        
                       
                </table>
        <input type="image" border=0 src="/template/submit.gif" alt="Submit Changes">
                </form> 
        };                      
                                

}
