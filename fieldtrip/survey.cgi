#!/usr/bin/perl

##################################################################
#       Scott Thompson - (june/2000)
##################################################################

use lib '/tnmc';
use tnmc;
require 'fieldtrip/FIELDTRIP.pl';

    #############
    ### Main logic

    &header();

    %survey;
    $cgih = new CGI;

    $tripID = $cgih->param('tripID');
    $userID = $cgih->param('userID');
    if (!$userID){$userID = $USERID;}    
    
           &get_tripSurvey($tripID, $userID, \%survey);
           &get_trip($tripID, \%trip);
    &get_user($trip{AdminUserID}, \%TripAdminUser);

    $selInterest{$survey{interest}} = 'selected';
    $selDriving{$survey{driving}} = 'selected';
    $selDrivingWith{$survey{drivingWith}} = 'selected';
      
    print qq {
        <form action="survey_submit.cgi" method="post">
        <input type="hidden" name="userID" value="$userID">
        <input type="hidden" name="tripID" value="$tripID">
        
        <table cellpadding="1" border="0" cellspacing="0">

            <tr valign=top>
                <td><b>Are you coming?</b></td>
                <td>
                    <select name="interest" size="1">
                    <option value="0" $selInterest{0}>
                    <option value="3" $selInterest{3}>Yes!! I'm coming for sure!
                    <option value="2" $selInterest{2}>Probably, but i'm not commited yet.
                    <option value="1" $selInterest{1}>Maybe, Keep me posted..
                    <option value="-1" $selInterest{-1}>Nope.
                    </select>
                    </td>
                </tr>
            <tr><td colspan="10"><hr noshade size="2"></td></tr>
            <tr valign="top">
                <td><b>Rides</b></td>
                <td>Can you drive?
                    <select name="driving" size="1">
                    <option value="0" $selDriving{0}>
                    <option value="2" $selDriving{2}>Yes
                    <option value="1" $selDriving{1}>If i need to
                    <option value="-1" $selDriving{-1}>Nope
                    </select>
                    </td>
                </tr>
            <tr valign=top>
                <td><b></b></td>
                <td>Seats (total):
                    <input type="text" name="drivingSeats" value="$survey{drivingSeats}" size="2">
                    </td>
                </tr>
            <tr valign=top>
                <td><b></b></td>
                <td>Ride with (userid):
                    <select name="drivingWith">
                    <option value="0" $selDrivingWith{0}>
    };
        $sql = qq{SELECT s.userID, p.username, s.driving
                    FROM FieldtripSurvey as s, Personal as p
           WHERE (s.tripID = '$tripID') AND (s.userID = p.userID) AND (s.driving >= '2') AND (s.interest >= '2')
           ORDER BY s.driving DESC, s.interest DESC};
        $sth = $dbh_tnmc->prepare($sql);
        $sth->execute();
    while (@row = $sth->fetchrow_array()){
        print qq{
                    <option value="$row[0]" $selDrivingWith{$row[0]}>$row[1]
        };
    }
    print qq{
                    </select>
                    </td>
                </tr>

            <tr><td colspan="10"><hr noshade size="2"></td></tr>
            <tr valign="top">
                <td><b>Depart</b></td>
                <td>
                    <input type="text" name="departDate" value="$survey{departDate}">
                </tr>
            <tr valign="top">
                <td><b>Return</b></td>
                <td>
                    <input type="text" name="returnDate" value="$survey{returnDate}">
                </tr>

            <tr><td colspan="10"><hr noshade size="2"></td></tr>
            <tr valign="top">
                <td><b>Amount Paid to $TripAdminUser{username}</b></td>
                <td>
                    <input type="text" name="MoneyPaid" value="$survey{MoneyPaid}">
                </tr>
            <tr valign="top">
                <td><b>Shared Expenses</b></td>
                <td>
                    <input type="text" name="MoneyExpenseShared" value="$survey{MoneyExpenseShared}">
                </tr>
            <tr valign="top">
                <td><b>Pro-Rated Expenses</b></td>
                <td>
                    <input type="text" name="MoneyExpenseProRated" value="$survey{MoneyExpenseProRated}">
                </tr>
            <tr valign="top">
                <td><b>Pro-Rated Portion</b></td>
                <td>
                    <input type="text" name="MoneyExpensePortion" value="$survey{MoneyExpensePortion}">
                </tr>
            <tr valign="top">
                <td><b>Notes:</b></td>
                <td>
                    <textarea name="MoneyNotes" cols="20" rows="5">$survey{MoneyNotes}</textarea>
                </tr>

        </table>
        <input type="submit" value="Submit">
        </form>
    }; 
    

    &footer();
