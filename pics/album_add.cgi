#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;


#############
### Main logic

&db_connect();
&header();

&show_album_add_form();

&footer();
&db_disconnect();


sub show_album_add_form{
    
    print qq {
	<form action="album_add_submit.cgi" method="post">
        
        <input type="hidden" name="albumID" value="0">
        <input type="hidden" name="albumOwnerID" value="$USERID">

	<table>

        <tr><td><b>Title</td>
            <td><input type="text" name="albumTitle" value=""></td>
            </tr>

        <tr><td><b>Start Date</td>
            <td><input type="text" name="albumDateStart" value=""></td>
            </tr>

        <tr><td><b>End Date</td>
            <td><input type="text" name="albumDateEnd" value=""></td>
            </tr>

        <tr><td><b>Description</td>
            <td><textarea name="albumDescription" wrap="virtual" rows="5"></textarea></td>
            </tr>
        <tr><td><b>Public</td>
            <td><input type="radio" name="albumTypePublic" value="1">Yes
                <input type="radio" name="albumTypePublic" value="0" checked>No
                </td>
            </tr>
        
        </table>
        <input type="submit" value="Submit">
	</form>
    }; 

}
