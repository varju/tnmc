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
use tnmc::movies::night;
use tnmc::cgi;

{
    #############
    ### Main logic
    
    &header();
    
    my %night;	
    my $nightID = &tnmc::cgi::param('nightID');
	
    &get_night($nightID, \%night);
    
    print qq{
		<form action="night_edit_admin_submit.cgi" method="post">
		<table>
                };
    
    foreach my $key (keys(%night)){
        print qq {
            <tr valign=top><td>$key</td>
            };
		
        if ($key =~ /blurb/i){
            print qq {<td><textarea cols="20" rows="4" wrap="virtual" name="$key">$night{$key}</textarea></td>};
        }
        else{
            print qq {<td><input type="text" name="$key" value="$night{$key}"></td>};
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



