#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::template;
use tnmc::util::date;


#############
### Main logic

&tnmc::template::header();

&show_album_add_form();

&tnmc::template::footer();

#
# subs
#

sub show_album_add_form{
    &tnmc::template::show_heading("Add a new Album");
    my $now = &tnmc::util::date::now();
    print qq {
	<form action="album_add_submit.cgi" method="post">
        
        <input type="hidden" name="albumID" value="0">
        <input type="hidden" name="albumOwnerID" value="$USERID">

	<table>

        <tr><td><b>Title</td>
            <td><input type="text" name="albumTitle" value=""></td>
            </tr>

        <tr><td><b>Description</td>
            <td><textarea name="albumDescription" wrap="virtual" rows="5"></textarea></td>
            </tr>

        <tr><td><b>Access</td>
            <td>
                <select name="albumTypePublic">
                    <option value="2">Public view/edit
                    <option value="1">Public view
                    <option selected value="0">Hidden
                </select>
                </td>
            </tr>
        
        <tr><td nowrap><b>Start Date</td>
            <td><input type="text" name="albumDateStart" value="$now"></td>
            </tr>

        <tr><td><b>End Date</td>
            <td><input type="text" name="albumDateEnd" value="$now"></td>
            </tr>

        <tr><td colspan="2">
            Do you want to pre-fill the album with all available
            pictures that are in the above date range?
            </td></tr>
        <tr><td></td>
            <td>
                <select name="optionFill">
                    <option value="0">No
                    <option value="1">Yes
                </select>
            </td></tr>
        </table>
        <input type="submit" value="Submit">
	</form>
    }; 

}
