#!/usr/bin/perl

##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

use lib '/usr/local/apache/tnmc/';
use tnmc;

{
    #############
    ### Main logic
    
    &db_connect();
    &header();
    
    %user;	
    $cgih = new CGI;
    
    $heading = "dev job list";
    if ($USERID{groupDev} >= 1){
        $heading .= qq{ - <a href="/development/todo_list.cgi"><font color="ffffff">Edit</font></a>};
    }
    &show_heading ($heading);
    $devBlurb =  &get_general_config("devBlurb");
    $devBlurb =~ s/\n/<br>/gs;
    print $devBlurb;
    
    $heading = "suggestion box";
    if ($USERID{groupDev} >= 1){
        $heading .= qq{ - <a href="/development/suggestions.cgi"><font color="ffffff">Edit</font></a>};
    }
    $heading .= qq{ - <a href="/user/suggestion_add.cgi"><font color="ffffff">Submit</font></a>};

    &show_heading ($heading);
    $suggBlurb =  &get_general_config("suggestions");
    $suggBlurb =~ s/\n/<br>/gs;
    print $suggBlurb;
    
    
    &footer();

}




