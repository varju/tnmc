#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::general_config;
use tnmc::template;
use tnmc::movies::movie;
use tnmc::movies::night;
use tnmc::movies::show;

#############
### Main logic

&header();

## List of Future Nights
&show_heading ("future nights");
my @NIGHTS = &list_future_nights();
foreach my $nightID (@NIGHTS){
    my %night;
    &get_night ($nightID, \%night);
    print qq{
        <a href="night_edit.cgi?nightID=$nightID">$night{date}</a>
            ($nightID)<br>
    };
}
    
&show_current_nights();

&footer();




