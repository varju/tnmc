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

{
    #############
    ### Main logic

    &tnmc::db::db_connect();
    &tnmc::template::header();

    my $heading = "dev job list";
    if ($USERID{groupDev} >= 1) {
        $heading .= qq{ - <a href="development/todo_list.cgi"><font color="ffffff">Edit</font></a>};
    }
    &tnmc::template::show_heading($heading);

    my $devBlurb = &tnmc::general_config::get_general_config("devBlurb");
    $devBlurb =~ s/\n/<br>/gs;
    print "<p>" . $devBlurb;

    $heading = "suggestion box";
    if ($USERID{groupDev} >= 1) {
        $heading .= qq{ - <a href="development/suggestions.cgi"><font color="ffffff">Edit</font></a>};
    }
    $heading .= qq{ - <a href="user/suggestion_add.cgi"><font color="ffffff">Submit</font></a>};
    &tnmc::template::show_heading($heading);

    my $suggBlurb = &tnmc::general_config::get_general_config("suggestions");
    $suggBlurb =~ s/\n/<br>/gs;
    print "<p>" . $suggBlurb;

    &tnmc::template::footer();
    &tnmc::db::db_disconnect();
}
