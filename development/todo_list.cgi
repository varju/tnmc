#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
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

    my (@movies, $movieID, %movie);
    
    if ($USERID)
    {     &show_heading ("dev job list");

        &get_user($userID, \%user);
      
        $devBlurb =  &get_general_config("devBlurb");

        print qq 
                {       <form action="development_set_submit.cgi" method="post">
                        <table>
        
                        <tr>
                        <td><textarea cols=40 rows=30 wrap=virtual name="devBlurb">$devBlurb</textarea></td>
                        </tr>

            </table>

            <p>
                        <input type="image" border=0 src="/template/submit.gif" alt="Submit Changes">

            </form>
        }; 
    }
    

    &footer();

