#!/usr/bin/perl

##################################################################
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

use lib '/usr/local/apache/tnmc';
use tnmc;


    #############
    ### Main logic

    &db_connect();
    &header();

    %user;    
    $cgih = new CGI;
    $userID = $cgih->param('userID');
    
    if ($userID)
    { 
         @cols = &db_get_cols_list($dbh_tnmc, 'Personal');
            &get_user($userID, \%user);
          
        print qq 
        {    <form action="user_edit_submit.cgi" method="post">
            <table>
        };
    
        foreach $key (@cols)
            {       print qq 
            {    
                <tr><td><b>$key</td>
                    <td><input type="text" name="$key" value="$user{$key}"></td>
                </tr>
            };
            }
    
        print qq
        {    </table>
            <input type="submit" value="Submit">
            </form>
        }; 
    }
    

    &footer();

    &db_disconnect();
