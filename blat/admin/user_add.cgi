#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;

use lib "/scottt/htdocs/tasks/";

use task::db;
use task::user;
use task::template;
use task::cgi;

#############
### Main logic

print "Content-Type: text/html; charset=utf-8\n\n";

#&header();

&show_heading("add user");
print qq {
    <form action="user_add_submit.cgi" method="post">
    <table>
        <tr><td><b>userid</b></td>
        <td><input type="text" name="Username" value=""> (the same as your unix account)</td>
        </tr>
    </table>
    <input type="submit" value="Submit">
    </form>
};

#&footer();
