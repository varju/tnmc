#!/usr/bin/perl


use lib '/tnmc';
use tnmc;

#
# Common Variables
#

&tnmc::teams::htmlTemplate::change_template();

my $script_name = "teams/index.cgi";

#
# Actions
#

my $ACTION = lc( &tnmc::cgi::param("ACTION"));

if ($ACTION eq 'list'){
    &action_main();
}
else{
    &action_main();
}

#
# Action Subs
#

sub action_main{
    &tnmc::template::header();
    
    my $teamID = &tnmc::cgi::param("teamID");
    
    &tnmc::teams::template::show_team($teamID, 'teampage');
    &tnmc::teams::template::show_team_schedule($teamID);
    &tnmc::teams::template::show_team_roster($teamID);
    
    &tnmc::template::footer();
}









