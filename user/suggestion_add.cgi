#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::general_config;
use tnmc::template;
use tnmc::user;

{
    #############
    ### Main logic

    &tnmc::db::db_connect();
    &tnmc::template::header();

    &tnmc::template::show_heading("Make a Suggestion / Report a Bug");

    print qq{
        <form action="user/suggestion_submit.cgi" method="post">
        <table><tr><td>
    <textarea cols=40 rows=10 wrap=virtual name="suggestion"></textarea>
    </td></tr></table>
    <p>
        <input type="image" border=0 src="/template/submit.gif" alt="Submit Changes">

    </form>
    };

    if ($USERID{groupTrusted} >= 1) {

        my $heading = "The Suggestion Box";
        if ($USERID{groupDev} >= 1) {
            $heading .= qq{ - <a href="development/suggestions.cgi"><font color="ffffff">Edit</font></a>};
        }
        &tnmc::template::show_heading($heading);

        my $suggBlurb = &tnmc::general_config::get_general_config("suggestions");
        $suggBlurb =~ s/\n/<br>/gs;
        print "<p>$suggBlurb<p>";

        $heading = "The To do List";
        if ($USERID{groupDev} >= 1) {
            $heading .= qq{ - <a href="development/todo_list.cgi"><font color="ffffff">Edit</font></a>};
        }
        &tnmc::template::show_heading($heading);

        my $devBlurb = &tnmc::general_config::get_general_config("devBlurb");
        $devBlurb =~ s/\n/<br>/gs;
        print "<p>$devBlurb<p>";
    }

    &tnmc::template::footer();
    &tnmc::db::db_disconnect();
}

