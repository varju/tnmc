#!/usr/bin/perl

##################################################################
#       Scott Thompson - (apr/2001)
##################################################################

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::user;

require 'fieldtrip/FIELDTRIP.pl';

#############
### Main logic

&header();

$cgih = new CGI;
$tripID = $cgih->param('tripID');

show_edit_form($tripID);

&footer();


##################################################
sub show_edit_form{
    my ($tripID) = @_;


    %trip;
    
    &get_trip($tripID, \%trip);
    
    &show_heading("trip edit");
    print qq {
        <form action="trip_edit_submit.cgi" method="post">
        <input type="hidden" name="tripID" value="$tripID">
        <table>
         
        <tr><th colspan="2">basic info</th></tr>

        <tr><td><b>title</b></td>
            <td><input type="text" name="title" value="$trip{title}"></td></tr>
        <tr><td><b>description</b></td>
            <td><textarea cols="20" rows="5" name="description">$trip{description}</textarea></td></tr>

        <tr><td><b>blurb</b></td>
            <td><textarea cols="20" rows="5" name="blurb">$trip{blurb}</textarea></td></tr>

        <tr><th colspan="2">date/time</th></tr>

        <tr><td><b>useWhen</b></td>
            <td><input type="text" name="useWhen" value="$trip{useWhen}"></td></tr>
        <tr><td><b>startTime</b></td>
            <td><input type="text" name="startTime" value="$trip{startTime}"></td></tr>
        <tr><td><b>endTime</b></td>
            <td><input type="text" name="endTime" value="$trip{endTime}"></td></tr>

        <tr><th colspan="2">rides</th></tr>

        <tr><td><b>useRides</b></td>
            <td><input type="text" name="useRides" value="$trip{useRides}"></td></tr>

        <tr><th colspan="2">cost</th></tr>

        <tr><td><b>useCost</b></td>
            <td><input type="text" name="useCost" value="$trip{useCost}"></td></tr>
        <tr><td><b>cost</b></td>
            <td><input type="text" name="cost" value="$trip{cost}"></td></tr>

        <tr><th colspan="2">questionaire</th></tr>


        </table>
        <input type="submit" value="Submit">
        </form>
    };

}
