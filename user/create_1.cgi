#!/usr/bin/perl

##################################################################
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::db;
use tnmc::template;

#############
### Main logic

&tnmc::db::db_connect();
&tnmc::template::header();

if (1) {
    &tnmc::template::show_heading("Account creation temporarily disabled");
}
else {
    my @cols = &tnmc::db::db_get_cols_list('Personal');

    print qq{
            <form action="user/create_2.cgi" method="post">
            <input type="hidden" name="userID" value="0">
            };

    &tnmc::template::show_heading("Create New Account: Step 1");

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
}

&tnmc::template::footer();
