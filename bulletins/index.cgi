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

    my (@movies, $movieID, %movie);
    
    if ($USERID)
    {     &show_heading ("set bulletins");

        &get_user($userID, \%user);
      
        $bulletins =  &get_general_config("bulletins");

        print qq 
                {       <form action="bulletins_set_submit.cgi" method="post">
                        <table>
        
                        <tr>
                        <td><textarea cols=40 rows=15 wrap=virtual name="bulletins">$bulletins</textarea></td>
                        </tr>

            </table>

            <p>
                        <input type="image" border=0 src="/template/submit.gif" alt="Submit Changes">

            </form>
        }; 
    }
    

    &footer();

