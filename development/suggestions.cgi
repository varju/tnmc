#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::general_config;
use tnmc::template;

#############
### Main logic

&tnmc::db::db_connect();
&tnmc::template::header();

if ($USERID) {
    &tnmc::template::show_heading ("suggestions");
    
    my $suggestions = &tnmc::general_config::get_general_config("suggestions");
    
    print qq 
    {       <form action="fieldtrip/development_set_submit.cgi" method="post">
                        <table>
        
                        <tr>
                        <td><textarea cols=40 rows=30 wrap=virtual name="suggestions">$suggestions</textarea></td>
                        </tr>

            </table>

            <p>
                        <input type="image" border=0 src="/template/submit.gif" alt="Submit Changes">

            </form>
            }; 
}

&tnmc::template::footer();
&tnmc::db::db_disconnect();
