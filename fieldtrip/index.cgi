#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca         
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::user;

require 'fieldtrip/FIELDTRIP.pl';

#############
### Main logic

&db_connect();
&header();

my @trips;
&list_trips(\@trips, 'WHERE is_active = 1', 'ORDER BY starttime DESC');
foreach my $tripID (@trips){
    show_trip($tripID);
}

&footer();
db_disconnect();


#######################################
sub show_trip{
    my ($tripID) = @_;
    
    my (%trip);
    &get_trip($tripID, \%trip);

    my ($edit_link, $del_link, $survey_link, $view_link);

    if ($USERID eq $trip{AdminUserID}){
        $edit_link = qq{ - <a href="trip_edit.cgi?tripID=$tripID"><font color="ffffff">edit</font></a>};
        $del_link = qq{ - <a href="trip_del.cgi?tripID=$tripID"><font color="ffffff">del</font></a>};
    }
    
    ### survey link
    if ($USERID){
        $survey_link = qq{ - <a href="survey.cgi?tripID=$tripID&userID=$USERID"><font color="ffffff">survey</font></a>};
    }
    ### view link
    $view_link = qq{ - <a href="trip_view.cgi?tripID=$tripID"><font color="ffffff">view</font></a>};
    
    &show_heading($trip{title} . $view_link . $edit_link . $del_link . $survey_link);
    
    
    $sql = qq{SELECT COUNT(*), SUM(interest) FROM FieldtripSurvey WHERE (tripID = '$tripID') AND (interest >= '1')};
    $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();
    ($InterestT, $InterestA) = $sth->fetchrow_array();
    $InterestA = int ($InterestA / 3);
    
    $sql = qq{SELECT COUNT(*) FROM FieldtripSurvey WHERE (tripID = '$tripID') AND (interest = '3')};
    $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();
    ($Interest3) = $sth->fetchrow_array();
    
    print qq{
        <p>
        $trip{description}
        <p>
        <b>People:</b>  $InterestT total, $Interest3 commited, estimate $InterestA show
     };

    if ($trip{useCost}){
        $sql = qq{SELECT SUM(MoneyExpenseProRated), SUM(MoneyExpenseShared), SUM(MoneyExpensePortion), SUM(MoneyPaid)
                        FROM FieldtripSurvey WHERE (tripID = '$tripID') AND (interest >= '1')};
        $sth = $dbh_tnmc->prepare($sql);
        $sth->execute();
        ($EXPpro, $EXPshare, $EXPsum, $EXPpaid) = $sth->fetchrow_array();
    }

    ####################
    ### userlist
    $sql = qq{SELECT p.userID, interest, driving, 
             DATE_FORMAT(departDate, '%a %l:%i %p'),
             DATE_FORMAT(returnDate, '%a %l:%i %p')
            FROM FieldtripSurvey AS f LEFT JOIN Personal AS p USING (userID)
           WHERE (tripID = '$tripID') AND interest >= '1'
           ORDER BY p.username};
    $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();

    print qq{
        <table border="0" cellpadding="1" cellspacing="0" width="100%">
        <tr>    
            <th>&nbsp;</th>
            <th>&nbsp;</th>
            <th colspan="2">ride</th>
            <th>depart/return</th>
            <th>Cost</th>
            <th>Balance</th>
            </tr>
    };

    my $i = 0;
    while (@row = $sth->fetchrow_array()){
        $i ++;
        &get_user($row[0], \%user);
        &get_tripSurvey($tripID, $row[0], \%survey);
        
        if     ($survey{interest} == 3)  {    $font = '<b>';}
        elsif    ($survey{interest} == 1)  {    $font = '<font color="888888">';}
        elsif    ($survey{interest} == -1) {    $font = '<font color="ff0000">';}
        else                              {    $font = '';}
        
        if ($USERID == $trip{AdminUserID}){
            $edit = qq{<a href="survey.cgi?tripID=$tripID&userID=$row[0]">$i</a></td>};
        }else{    $edit = $i;}
        
        print qq{
            <tr>
                <td>$edit</td>
                <td>$font$user{username}</td>
        };

        if ($trip{useWhen}){
            print qq{
                <td nowrap>($row[3] - $row[4])</td>
            };
        }
        
        if ($trip{useRides}){
            if($survey{drivingWith}){
                &get_user($survey{drivingWith}, \%driver);
                print qq{<td>$driver{username}</td>};
            }else{
                print qq{<td></td>};
            }
            if    ($survey{driving} == 2){    print qq{<td>*</td>};}
            elsif ($survey{driving} == 1){    print qq{<td>+</td>};}
            else              {    print qq{<td></td>};}
        }
        
        if ($trip{useCost}){
#                my $myCost = ($EXPshare / $Interest3) + ($EXPpro / $EXPsum * $survey{MoneyExpensePortion});
#                my $myBalance = $myCost - $survey{MoneyExpenseProRated} - $survey{MoneyExpenseShared} - $survey{MoneyPaid};
            
            if ($row[0] == 1){
                $myBalance += $EXPpaid;
            }

            $myCost = int($myCost * 100) / 100;
            $myBalance = int($myBalance + 0.5);
            print qq{
                <td nowrap align="right">&nbsp; \$$myCost</td>
                <td nowrap align="right">&nbsp; \$$myBalance</td>
            };
        }
            
        print qq{
            </tr>
        };
    }
    print qq{    </table><br>};


    if ($USERID eq $trip{AdminUserID}){
        
        print qq{
            <form method=get action="survey.cgi">
            <input type="hidden" name="tripID" value="$tripID">
            <select name="userID">
        };

        my $users = get_user_list();
        foreach $username (sort keys %$users){
            print qq{<option value="$users->{$username}">$username\n};
        }
        print qq{
            </select>
            <input type="submit" value="go">
            </form>
        };

    }
}

