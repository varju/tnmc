#!/usr/bin/perl


use lib '/tnmc';
use tnmc;

#
# Common Variables
#

my $script_name = "teams/index.cgi";


#
# Actions
#

my $ACTION = lc( &tnmc::cgi::param("ACTION"));

if ($ACTION eq 'list'){
    &action_list_teams();
}
else{
    &action_list_teams();
}

#
# Action Subs
#

sub action_list_teams{
    
    # setup
    my @teams = &tnmc::teams::team::list_teams("ORDER BY seasonStart");
    
    # show page
    &tnmc::template::header();
    
    &tnmc::template::show_heading("Teams");
    map {&tnmc::teams::template::show_team($_, 'big');} @teams;
    
    &tnmc::template::footer();
}




