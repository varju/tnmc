#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc/';

use tnmc::db;
use tnmc::template;
use tnmc::movies::movie;
use tnmc::movies::night;
use tnmc::movies::attend;

{
    #############
    ### Main logic
    
    &db_connect();
    &header();
    
    my $next = &get_next_night();
    
    my %next;
    &get_night($next, \%next);
    print qq{Next? <a href="night_edit_admin.cgi?nightID=$next{nightID}">$next{date}</a>};
    
    print "<hr>";
    
    my @nights;
    list_nights(\@nights, "", "ORDER BY date DESC");
    
    foreach my $nightID (@nights){
        my %night;
        get_night ($nightID, \%night);
        print qq{
            <a href="night_edit_admin.cgi?nightID=$nightID">$night{date}</a>
                ($nightID)<br>
                };
    }
    
    &footer();
    &db_disconnect();
}
