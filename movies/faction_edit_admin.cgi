#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
#	Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc/';

use tnmc::template;
use tnmc::movies::faction;
use tnmc::cgi;
use tnmc::db;

{
    #############
    ### Main logic
    
    &tnmc::template::header();
    
    my $factionID = &tnmc::cgi::param('factionID');
    
    my $faction = &tnmc::movies::faction::get_faction($factionID);
    my @cols = &tnmc::db::db_get_cols_list("MovieFactions");
    
    print qq{
		<form action="faction_edit_admin_submit.cgi" method="post">
		<table>
                };
    
    foreach my $key (@cols){
        print qq {
            <tr valign=top><td>$key</td>
        };

        print qq {<td><input type="text" name="$key" value="$faction->{$key}"></td>};

        print "</tr>";
    }
    
    print qq{
		</table>
		<input type="submit" value="Submit">
		</form>
                }; 
    
    
    &tnmc::template::footer();
}



