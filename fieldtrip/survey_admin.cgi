#!/usr/bin/perl

##################################################################
#       Scott Thompson - (june/2000)
##################################################################

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::user;
use tnmc::cgi;

require 'fieldtrip/FIELDTRIP.pl';

    #############
    ### Main logic

    &header();

    %survey;

    $tripID = &tnmc::cgi::param('tripID');
    $userID = &tnmc::cgi::param('userID');
    if (!$userID){$userID = $USERID;}    
    
           &get_tripSurvey($tripID, $userID, \%survey);
      
    print qq {
        <form action="survey_submit.cgi" method="post">
        
        <table>
    };

    foreach $key (keys(%survey)){       
    
        print qq{
            <tr valign=top><td><b>$key</b></td>
            <td><input type="text" name="$key" value="$survey{$key}"></td>
            </tr>
        };
           }

    print qq
    {    </table>
        <input type="submit" value="Submit">
        </form>
    }; 
    

    &footer();
