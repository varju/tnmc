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
    

     @cols = &db_get_cols_list($dbh_tnmc, 'Personal');

    print qq{
        <form action="create_2.cgi" method="post">
        <input type="hidden" name="userID" value="0">
    };

    &show_heading ("Create New Account: Step 1");

    print qq{
        <table>
                                <tr><td><b>username</td>
                                    <td><input type="text" name="username" value=""></td>
                                </tr>
                               
                                <tr><td><b>full name</td>
                                    <td><input type="text" name="fullname" value=""></td>
                                </tr>
                                
                                <tr><td><b>email</td>
                                    <td><input type="text" name="email" value=""></td>
                                </tr>
                                
                                <tr><td><b>password</td>
                                    <td><input type="text" name="password" value=""></td>
                                </tr>

            </table>
            <p>

            <input type="image" border=0 src="/template/submit.gif" alt="Submit Changes">
            </form>
    }; 

    

    &footer();

