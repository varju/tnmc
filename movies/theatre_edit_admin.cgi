#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
#	Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc/';

use tnmc::security::auth;
use tnmc::template;
use tnmc::movies::theatres;
use tnmc::cgi;
use tnmc::db;

{
    #############
    ### Main logic
    
    &header();
    
    my %hash;	
    my $ID = &tnmc::cgi::param('theatreID');
    
    my $hash = &tnmc::movies::theatres::get_theatre($ID);
    
    print qq{
		<form action="theatre_edit_admin_submit.cgi" method="post">
		<table>
                };
    my @cols = &db_get_cols_list('MovieTheatres');
    foreach my $key (sort @cols){
        print qq {
            <tr valign=top><td>$key</td>
            };
		
        if ($key =~ /blurb/i){
            print qq {<td><textarea cols="20" rows="4" wrap="virtual" name="$key">$hash->{$key}</textarea></td>};
        }
        else{
            print qq {<td><input type="text" name="$key" value="$hash->{$key}"></td>};
        }
        
        print "</tr>";
    }
    
    print qq{
		</table>
		<input type="submit" value="Submit">
		</form>
                }; 
    
    
    &footer();
}



